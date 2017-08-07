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

require 'rails_helper'

RSpec.describe WishlistItem, type: :model do
  it{ is_expected.to belong_to :wishlist }
  it{ is_expected.to belong_to :work }
end
