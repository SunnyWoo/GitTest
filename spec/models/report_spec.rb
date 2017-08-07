# == Schema Information
#
# Table name: reports
#
#  id                    :integer          not null, primary key
#  order_id              :integer
#  user_id               :integer
#  user_role             :string(255)
#  order_item_num        :integer
#  price                 :integer
#  coupon_price          :integer
#  shipping_fee          :integer
#  country_code          :string(255)
#  platform              :string(255)
#  date                  :date
#  created_at            :datetime
#  updated_at            :datetime
#  subtotal              :integer
#  refund                :integer
#  total                 :integer
#  shipping_fee_discount :integer
#

require 'spec_helper'

RSpec.describe Report, :type => :model do
  it 'FactoryGirl' do
    expect( build(:report) ).to be_valid
  end

  it { should belong_to(:user) }
  it { should belong_to(:order) }
  it { should validate_uniqueness_of(:order_id) }
end
