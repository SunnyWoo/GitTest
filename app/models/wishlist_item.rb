# == Schema Information
#
# Table name: wishlist_items
#
#  id          :integer          not null, primary key
#  wishlist_id :integer
#  work_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class WishlistItem < ActiveRecord::Base
  belongs_to :wishlist
  belongs_to :work
end
