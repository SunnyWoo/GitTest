# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  name       :string(255)
#

class Tag < ActiveRecord::Base
  translates :text, fallbacks_for_empty_translations: true
  globalize_accessors
  accepts_nested_attributes_for :translations, allow_destroy: true

  has_many :taggings, dependent: :destroy
  has_many :work_taggings, -> { work_taggings }, class_name: 'Tagging'
  has_many :works, -> { is_public }, through: :taggings, source: :taggable, source_type: 'Work'
  has_many :standardized_works, -> { is_public }, through: :taggings, source: :taggable, source_type: 'StandardizedWork'
  has_many :collection_tags, dependent: :destroy
  has_many :collections, through: :collection_tags

  validates :name, uniqueness: true, presence: true, format: { with: /\A[a-zA-Z0-9_-]+\z/i }
  validates :text_en, presence: true

  after_commit :touch_works

  def self.[](text)
    find_by(text: text)
  end

  def self.create_by_name(name)
    tag = Tag.new(name: name)
    I18n.available_locales.each do |locale|
      text = name if locale == :en
      tag.translations.build(locale: locale, text: text)
    end
    fail RecordInvalidError.new(tag.errors.full_messages.join(',')) unless tag.valid?
    tag.save!
    tag
  end

  def text_all_locale
    text_translations.values.uniq.join(',')
  end

  def touch_works
    works.find_each(&:touch)
    standardized_works.find_each(&:touch)
  end
end
