# == Schema Information
#
# Table name: home_slides
#
#  id         :integer          not null, primary key
#  slide      :string(255)
#  is_enabled :boolean          default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#  title      :text
#  link       :string(255)
#  template   :integer          default(0)
#  desc       :hstore
#  background :string(255)
#  priority   :integer          default(1)
#  set        :string(255)
#

class HomeSlide < ActiveRecord::Base
  AVAILABLE_SETS = %w(default bottom_kv create)
  include MissingLocalesBuilder

  store_accessor :desc, :title2, :title3, :content1, :content2, :content3

  scope :enabled, -> { where(is_enabled: true) }

  mount_uploader :background, SlideUploader

  enum template: [:kv_middle, :kv_right, :kv_left]
  validates :link, url: true
  validates :set, inclusion: AVAILABLE_SETS
  validates_presence_of :slide, locale: :en
  validates :set, presence: true

  translates :slide, :title, fallbacks_for_empty_translations: true
  globalize_accessors

  accepts_nested_attributes_for :translations

  default_scope { order('priority DESC, created_at DESC') }

  Translation.mount_uploader :slide, SlideUploader
end
