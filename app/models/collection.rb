# == Schema Information
#
# Table name: collections
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Collection < ActiveRecord::Base
  translates :text, fallbacks_for_empty_translations: true
  globalize_accessors
  accepts_nested_attributes_for :translations, allow_destroy: true

  has_many :collection_tags, dependent: :destroy
  has_many :tags, through: :collection_tags
  has_many :taggings, through: :tags
  has_many :works, through: :tags
  has_many :standardized_works, through: :tags
  has_many :collection_works, dependent: :destroy

  validate :validates_text_should_be_unique_for_every_locales
  validates :text_en, presence: true

  after_commit :touch_works

  def self.[](text)
    find_by(text: text)
  end

  def text_all_locale
    text_translations.values.uniq.join(',')
  end

  def remove_tag(tag)
    collection_tag = collection_tags.find_by(tag_id: tag.id)
    collection_tag.destroy
  end

  private

  def validates_text_should_be_unique_for_every_locales
    taken = text_translations.any? do |locale, text|
      Collection::Translation.where('collection_id != ?', id || 0).where(locale: locale, text: text).exists?
    end
    errors.add(:text, :taken) if taken
  end

  def touch_works
    works.find_each(&:touch)
    standardized_works.find_each(&:touch)
  end
end
