# == Schema Information
#
# Table name: archived_artworks
#
#  id                  :integer          not null, primary key
#  original_artwork_id :integer
#  model_id            :integer
#  user_id             :integer
#  user_type           :string(255)
#  name                :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  application_id      :integer
#

class ArchivedArtwork < ActiveRecord::Base
  belongs_to :original_artwork, class_name: 'Artwork'

  belongs_to :product, class_name: 'ProductModel', foreign_key: :model_id
  belongs_to :user, polymorphic: true
  belongs_to :application, class_name: 'Doorkeeper::Application', foreign_key: 'application_id'
  has_many :works, class_name: 'ArchivedWork', foreign_key: :artwork_id

  validates :product, presence: true
  validates :user, presence: true

  delegate :name, to: :product, prefix: true

  accepts_nested_attributes_for :works

  def description
    ''
  end
end
