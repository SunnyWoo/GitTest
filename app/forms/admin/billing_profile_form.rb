class Admin::BillingProfileForm
  include ActiveModel::Model
  include ActiveModel::Validations

  VALID_TYPES = %w(address email).freeze

  attr_reader :profile, :type, :country_changed
  delegate :billable, :id, :persisted?,
           :name, :email, :phone,
           :address, :city, :state, :zip_code, :country_code,
           to: :profile

  def initialize(profile, type: 'address', country_changed: false)
    @profile = profile
    @address = profile.address_data
    @type = VALID_TYPES.include?(type) ? type : 'email'
    @country_changed = country_changed
  end

  def attributes=(attrs)
    @profile.attributes = attrs.except(:province_id, :dist_code)
    address = Address.new(attrs)
    @profile.address_data = address if address.present?
  end

  def save
    valid? && @profile.save
  end

  def with_province?
    china? && (@address.province_id.present? || country_changed?)
  end

  def with_district?
    (taiwan? || china?) && (@address.dist_code.present? || country_changed?)
  end

  def support_city_option?
    (@address.dist_code.present? || country_changed?) && (china? || taiwan?)
  end

  def district_options
    districts = china? ? DomainData::China::District : DomainData::Taiwan::District
    districts.map do |d|
      [d.fullname, d.code]
    end
  end

  def city_options
    cities = china? ? DomainData::China::City : DomainData::Taiwan::City
    cities.map do |c|
      [c.name, c.name]
    end
  end

  def province_options
    Province.normal.map do |p|
      [p.name, p.id]
    end
  end

  def dist_code
    @address.dist_code
  end

  def province_id
    @address.province_id
  end

  private

  def china?
    country_code == 'CN'
  end

  def taiwan?
    country_code == 'TW'
  end

  def country_changed?
    country_changed
  end

  def country_code
    @profile.country_code || @address.country_code
  end
end
