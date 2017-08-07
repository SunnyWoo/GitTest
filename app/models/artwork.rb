# == Schema Information
#
# Table name: artworks
#
#  id             :integer          not null, primary key
#  model_id       :integer
#  uuid           :string(255)
#  name           :string(255)
#  description    :text
#  work_type      :integer
#  finished       :boolean          default(FALSE)
#  featured       :boolean          default(FALSE)
#  position       :integer
#  created_at     :datetime
#  updated_at     :datetime
#  user_id        :integer
#  user_type      :string(255)
#  application_id :integer
#

class Artwork < ActiveRecord::Base
  include HasUniqueUUID

  belongs_to :product, class_name: 'ProductModel', foreign_key: :model_id
  belongs_to :user, polymorphic: true
  belongs_to :application, class_name: 'Doorkeeper::Application', foreign_key: 'application_id'
  has_many :works
  has_many :archives, class_name: 'ArchivedArtwork', foreign_key: :original_artwork_id
  has_many :wishlist_items
  has_many :wishlists, through: :wishlist_items
  has_many :taggings
  has_many :tags, through: :taggings

  validates :product, presence: true
  validates :user, presence: true

  delegate :name, to: :product, prefix: true

  WORK_TYPES = [:is_public, :is_private]
  enum work_type: WORK_TYPES

  def archived_attributes
    {
      model_id: model_id,
      user_id: user_id,
      user_type: user_type,
      name: name,
      application_id: application_id,
      works_attributes: works.map(&:archived_attributes)
    }
  end

  def create_archive
    archives.create(archived_attributes)
  end
end
