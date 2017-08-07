# == Schema Information
#
# Table name: coupon_notices
#
#  id         :integer          not null, primary key
#  coupon_id  :integer
#  notice     :string(255)
#  available  :boolean
#  platform   :json
#  region     :json
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe CouponNotice, type: :model do
  it 'FactoryGirl' do
    expect(build(:coupon_notice)).to be_valid
  end
end
