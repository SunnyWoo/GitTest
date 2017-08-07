module ActsAsTaggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable
    has_many :tags, through: :taggings
    has_many :collections, through: :tags
    after_create :set_tags
  end

  def set_tags
    if self.class.to_s.in? %w(Work StandardizedWork)
      self.tag_ids = product.tag_ids if product
    elsif self.class.to_s.in? %w(ProductModel)
      self.tag_ids = category.tag_ids if category
    end
  end

  def tag_ids=(ids)
    self.touch if self.persisted?
    @changed_attributes ||= {}
    @changed_attributes[:tag_ids] = tag_ids unless tag_ids.sort == ids.sort
    super
  end

  def tag_ids_changed?
    @changed_attributes.key?(:tag_ids)
  end

  def tag_names
    tags.map(&:name).uniq.join(',')
  end

  def collection_names
    collections.map(&:name).uniq.join(',')
  end

  def all_tags
    tags.map(&:text_all_locale).uniq.join(',')
  end

  def collection_positions
    result = {}
    collections.map do |collection|
      collection_work = collection_works.find_by(collection_id: collection.id)
      result[collection.name] = collection_work.try(:position)
    end
    result
  end

  def tag_positions
    result = {}
    tags.map do |tag|
      tagging = taggings.find_by(tag_id: tag.id)
      result[tag.name] = tagging.try(:position)
    end
    result
  end
end
