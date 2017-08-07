# == Schema Information
#
# Table name: wishlists
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Wishlist < ActiveRecord::Base
  belongs_to :user
  has_many :items, class_name: "WishlistItem"
  has_many :works, -> { select('DISTINCT ON (works.id) works.*') }, through: :items

  validates_uniqueness_of :user_id
end
