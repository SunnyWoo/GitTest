# == Schema Information
#
# Table name: billing_profiles
#
#  id            :integer          not null, primary key
#  address       :text
#  city          :string(255)
#  name          :string(255)
#  phone         :string(255)
#  state         :string(255)
#  zip_code      :string(255)
#  country       :string(255)
#  billable_id   :integer
#  billable_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  country_code  :string(255)
#  shipping_way  :integer          default(0)
#  email         :string(255)
#  type          :string(255)
#  address_name  :string(255)
#  memo          :hstore
#  province_id   :integer
#  address_data  :json
#

class BillingProfile < ActiveRecord::Base
  has_paper_trail
  store_accessor :memo, :from_address_info_id
  strip_attributes only: %i(city name phone state zip_code email address_name)

  belongs_to :billable, polymorphic: true
  belongs_to :province

  UNRANSACKABLE_ATTRIBUTES = %w(billable_id billable_type created_at updated_at)
  # 若有更新 countries_with_country_code 也要一起更新
  COUNTRY_CODES = %w(AU CA CN FR DE HK JP MO MY NZ SG KR TW GB US)

  serialize :address_data, Address

  delegate :dist, :dist_code, to: :address_data

  def self.ransackable_attributes(_auth_object = nil)
    (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end

  validates :country_code, presence: true, inclusion: { in: COUNTRY_CODES }
  validates :email, email: true
  validates :address, :phone, presence: true
  validate :check_input_english

  before_save :downcase_email

  enum shipping_way: [:standard, :express, :cash_on_delivery]

  def city_state
    administrative_area_names.reverse.join(' , ')
  end

  def administrative_area_names
    if address_data.present?
      address_data.administrative_areas
    else
      [state, province.try(:name), city].reject(&:blank?)
    end
  end

  def self.countries
    countries_with_country_code.keys
  end

  # 若有更新 COUNTRY_CODES 也要一起更新
  def self.countries_with_country_code
    {
      I18n.t('country.Australia') => 'AU',
      I18n.t('country.Canada') => 'CA',
      I18n.t('country.China') => 'CN',
      I18n.t('country.France') => 'FR',
      I18n.t('country.Germany') => 'DE',
      I18n.t('country.HongKong') => 'HK',
      I18n.t('country.Japan') => 'JP',
      I18n.t('country.Macao') => 'MO',
      I18n.t('country.Malaysia') => 'MY',
      I18n.t('country.NewZealand') => 'NZ',
      I18n.t('country.Singapore') => 'SG',
      I18n.t('country.SouthKorea') => 'KR',
      I18n.t('country.Taiwan') => 'TW',
      I18n.t('country.UnitedKingdom') => 'GB',
      I18n.t('country.UnitedStates') => 'US'
    }
  end

  def self.normalize_address_params(params)
    data = Hash(params).dup.symbolize_keys
    addr_attrs = data.slice(:country, :country_code, :state, :province_id, :province, :city, :address, :zip_code, :dist_code)
    data.delete(:dist)
    data.delete(:dist_code)
    data.delete(:province)
    data.merge(address_data: Address.new(addr_attrs)).with_indifferent_access
  end

  # 當轉成json時 null 的欄位轉成 ''
  #
  # @return json
  def as_json(opts = {})
    json = super(opts)
    Hash[*json.map { |k, v| [k, v || ''] }.flatten]
  end

  # Taiwan Format
  # china需要显示state（省份）
  def full_address
    return address_data.full_address if address_data.present?

    if country_code == 'CN'
      province_text = province.present? ? province_name : state
      "#{country} #{province_text} #{city} #{address}"
    else
      "#{country} #{city} #{address}"
    end
  end

  # Overwrite address attributes for
  %w(country_code state city zip_code address).each do |name|
    class_eval <<-RUBY
      def #{name}
        address_data.#{name} || read_attribute('#{name}')
      end
    RUBY
  end

  def country
    address_data.country || (country_code && BillingProfile.countries_with_country_code.invert[country_code])
  end

  def province_name
    province.try(:name)
  end

  def convert_legacy_address
    data = {
      country: country,
      country_code: country_code,
      city: city,
      address: address,
      zip_code: zip_code
    }.reject { |_, v| v.blank? }
    case country_code
    when 'TW'
    when 'CN'
      data[:province] = state
      data[:province_id] = Province.find_by('name LIKE ? OR name LIKE ?', "%#{state}%", "%#{city}%").try(:id)
    else # Global Format
      data[:state] = state
    end

    Address.new(data)
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def update_order_invoice_info
    if billable_type == 'Order' && billable.is_need_create_invoice? && billable.shipping_info.present?
      billable.update_invoice_info
    end
  end

  def check_input_english
    return if %w(HK MO CN JP TW).include? country_code
    %i(address name city).each do |attr|
      next if valid_input(send(attr)).blank?
      errors.add(attr, I18n.t('errors.input_engish'))
      return false
    end
  end

  def valid_input(input)
    input =~ /[^\u0000-\u007F]+/
  end
end
