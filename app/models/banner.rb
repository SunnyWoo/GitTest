# == Schema Information
#
# Table name: banners
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  image      :string(255)
#  image_meta :text
#  begin_on   :date
#  end_on     :date
#  countries  :string(255)      default([]), is an Array
#  created_at :datetime
#  updated_at :datetime
#  deeplink   :string(255)
#  platforms  :string(255)      default([]), is an Array
#  url        :string(255)
#

class Banner < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord

  PLATFORMS = %w(iOS Android)

  serialize :image_meta, OpenStruct

  mount_uploader :image, DefaultWithMetaUploader

  carrierwave_meta_composed :image_meta, :image, image_version: [:width, :height, :md5sum]

  scope :ordered, -> { order('begin_on asc') }
  scope :available, -> { where('begin_on <= :today and end_on >= :today', today: Date.today) }
  scope :in_country, ->(country_code) { where('? = any(countries)', country_code) }

  validates :platforms, subset_of: PLATFORMS, presence: true
  validates :url, format: { with: URI.regexp, message: "Must be URI format!" }, if: Proc.new { |a| a.url.present? }
  validate :either_url_or_deeplink

  SUPPORTED_COUNTRIES = [
    'Australia',
    'Canada',
    'China',
    'France',
    'Germany',
    'Hong Kong',
    'Japan',
    'Macao',
    'New Zealand',
    'Korea (South)',
    'Taiwan',
    'Singapore',
    'Malasia',
    'United Kingdom',
    'United States'
  ]

  def self.supported_countries
    SUPPORTED_COUNTRIES.map { |c| Country.find_country_by_name(c) }
  end

  def platforms=(value)
    super(value.reject(&:blank?))
  end

  def either_url_or_deeplink
    if (url.present? && deeplink.present?)
      errors.add(:url, I18n.t('banners.errors.either_url_or_deeplink'))
    end
  end
end
