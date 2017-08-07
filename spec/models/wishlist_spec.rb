# == Schema Information
#
# Table name: wishlists
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Wishlist, type: :model do
  it{ is_expected.to have_many :items }
  it{ is_expected.to have_many :works }
  it{ is_expected.to belong_to :user }
  it{ is_expected.to validate_uniqueness_of :user_id }
end
