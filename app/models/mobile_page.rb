# == Schema Information
#
# Table name: mobile_pages
#
#  id           :integer          not null, primary key
#  key          :string(255)
#  title        :string(255)
#  begin_at     :datetime
#  close_at     :datetime
#  is_enabled   :boolean          default(FALSE)
#  contents     :json
#  created_at   :datetime
#  updated_at   :datetime
#  page_type    :integer
#  country_code :string(255)
#

class MobilePage < ActiveRecord::Base
  include ActsAsIsEnabled
  COUNTRY_CODES = Region.china? ? %w(CN) : %w(TW JP EN)
  COUNTRY_CODE_DEFAULT = Region.china? ? 'CN' : 'TW'

  serialize :contents, Hashie::Mash.pg_json_serializer
  validates :key, presence: true, uniqueness: { scope: :country_code }
  validates :begin_at, :close_at, :page_type, presence: true
  validate :validates_page_type
  validate :validates_begin_at_and_close_at
  validates :country_code, presence: true, inclusion: { in: COUNTRY_CODES,
                                                        message: '%{value} is not a valid country code' }

  has_one :mobile_page_preview
  has_many :mobile_components
  accepts_nested_attributes_for :mobile_components, allow_destroy: true

  scope :campaign_page, -> { where(page_type: MobilePage.page_types.map { |k, v| v if k.match(/cam/) }.compact) }

  enum page_type: { homepage: 1, campaign_subject: 2, campaign_limited_time: 3, campaign_limited_quantity: 4 }

  def self.mapping_country_code(country_code)
    if Region.china?
      'CN'
    else
      case country_code
      when 'TW', 'HK', 'MO'
        'TW'
      when 'JP'
        'JP'
      else
        'EN'
      end
    end
  end

  protected

  def validates_page_type
    if page_type == 'homepage' && self.class.homepage.where(country_code: country_code).where.not(id: id).count > 0
      errors.add(:page_type, I18n.t('errors.page_type_homepage_only_once'))
    end
  end

  def validates_begin_at_and_close_at
    return unless begin_at.to_i > close_at.to_i
    errors.add(:begin_at, I18n.t('errors.invalid_begin_at_lt_close_at'))
  end
end
