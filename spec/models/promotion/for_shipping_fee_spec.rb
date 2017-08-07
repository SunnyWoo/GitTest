# == Schema Information
#
# Table name: promotions
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  description     :text
#  type            :string(255)      not null
#  aasm_state      :integer
#  rule            :integer
#  rule_parameters :json
#  targets         :integer
#  begins_at       :datetime
#  ends_at         :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  level           :integer
#

require 'spec_helper'

describe Promotion::ForShippingFee do
  before do
    stub_env('REGION', 'china')
    ImportShippingFeeService.import_china_shipping_fee
    allow_any_instance_of(Order).to receive(:weight).and_return(15_000)
    create :site_setting, key: 'ShippingFeeSwitch', value: 'true'
    create :promotion_for_shipping_fee, begins_at: Time.zone.now - 1.day, aasm_state: 'started'
    @shipping_info = create :shipping_info, country_code: 'CN', shipping_way: 'standard', province: Province.find_by_name('江西省')
  end

  context 'order Conform to the rules' do
    Given(:order_item) { create :order_item, quantity: 3 }
    context 'when shipping_way is standard' do
      Given!(:order) { create :order, :priced, currency: 'CNY', shipping_info: @shipping_info, order_items: [order_item] }
      Then { order.shipping_fee == order.shipping_fee_discount }
      And { order.shipping_fee == order.order_adjustments.select(&:for_shipping_fee?).sum(&:value) * -1 }
    end

    context 'when shipping_way is express' do
      Given { @shipping_info.update_attribute(:shipping_way, 'express') }
      Given!(:order) { create :order, :priced, currency: 'CNY', shipping_info: @shipping_info, order_items: [order_item] }
      Then { order.shipping_fee == ShippingFeeService.new(order, nil, 'express').price }
      And { order.shipping_fee_discount == [ShippingFeeService.new(order, nil, 'express').price, ShippingFeeService.new(order, nil, 'standard').price].min }
      And { order.shipping_fee_discount == order.order_adjustments.select(&:for_shipping_fee?).sum(&:value) * -1 }
    end
  end
end
