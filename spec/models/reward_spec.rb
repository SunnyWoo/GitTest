# == Schema Information
#
# Table name: rewards
#
#  id          :integer          not null, primary key
#  order_no    :string           not null
#  phone       :string
#  coupon_code :string
#  avatar      :string
#  cover       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe Reward, type: :model do
  it { should(validate_presence_of(:order_no)) }
  it { should validate_presence_of(:coupon_code) }
  it { should validate_presence_of(:avatar) }
  it { should validate_presence_of(:cover) }

  context '#valid' do
    Given(:reward) { build :reward }
    Then { reward.valid? }
    context 'can not be save for case that order billing_info_phone is blank' do
      before { allow(reward.order).to receive(:billing_info_phone).and_return(nil) }
      Then { reward.save == false }
      And { reward.errors[:phone].include? 'phone is missing' }
    end
  end

  context '#order' do
    context 'retuns order based on order_no' do
      Given(:reward) { create :reward }
      Then { reward.order.is_a? Order }
    end

    context 'raise ActiveRecord::NotFound with invalid order_no' do
      Given(:bad_reward) { create :reward, order_no: 'qweaasd' }
      Then { expect { bad_reward.order }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end

  context '#set_phone_from_order_billing_info' do
    Given(:reward) { build :reward }
    context 'returns true with order.billing_info_phone existent' do
      Then { reward.send(:set_phone_from_order_billing_info) == true }
      And { reward.phone.present? }
    end

    context 'returns false with order.billing_info_phone inexistent' do
      before { allow(reward.order).to receive(:billing_info_phone).and_return(nil) }
      Then { reward.send(:set_phone_from_order_billing_info) == false }
      And { reward.phone.blank? }
    end
  end
end
