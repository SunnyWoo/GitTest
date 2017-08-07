# == Schema Information
#
# Table name: asset_packages
#
#  id              :integer          not null, primary key
#  designer_id     :integer
#  icon            :string(255)
#  available       :boolean          default(FALSE), not null
#  begin_at        :date
#  end_at          :date
#  countries       :string(255)      default([]), is an Array
#  position        :integer
#  image_meta      :json
#  created_at      :datetime
#  updated_at      :datetime
#  category_id     :integer
#  downloads_count :integer          default(0)
#

class AssetPackage < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord
  attr_accessor :insert_position

  translates :name, :description
  globalize_accessors
  acts_as_list scope: :category

  mount_uploader :icon, DefaultWithMetaUploader
  carrierwave_meta_composed :image_meta, :icon, image_version: [:width, :height, :md5sum]

  serialize :image_meta, Hashie::Mash.pg_json_serializer

  belongs_to :designer
  belongs_to :category, class_name: 'AssetPackageCategory', foreign_key: :category_id, counter_cache: :packages_count
  has_many :assets, foreign_key: :package_id
  has_many :asset_package_collectings
  has_many :users, through: :asset_package_collectings

  validates :begin_at, :end_at, presence: { if: :available? }

  after_save :perform_insert

  scope :in_country, ->(country_code) { where('? = any(countries)', country_code) }
  scope :available, -> { where(available: true) }
  scope :unavailable, -> { where(available: false) }
  scope :ready, -> { available.where('begin_at > ?', Time.zone.today) }
  scope :on_board, -> { available.where('begin_at <= :today and end_at >= :today', today: Time.zone.today) }
  scope :off_board, -> { available.where('end_at < ?', Time.zone.today) }

  delegate :name, to: :category, allow_nil: true, prefix: true

  def perform_insert
    insert_at(insert_position.to_i) if insert_position
  end

  def count_download
    update_column :downloads_count, self.downloads_count += 1
    category.update_column :downloads_count, category.downloads_count += 1
  end

  Translation.class_eval do
    validates :name, :description, presence: true,
                                   if: -> (translation) { translation.locale.in? [:en, :'zh-TW'] }, on: :update
  end
end
