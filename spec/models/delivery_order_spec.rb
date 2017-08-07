# == Schema Information
#
# Table name: delivery_orders
#
#  id             :integer          not null, primary key
#  model_id       :integer
#  order_no       :string(255)
#  print_item_ids :integer          default([]), not null, is an Array
#  state          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

RSpec.describe DeliveryOrder, :type => :model do
  it 'auto generates order no' do
    delivery_order = DeliveryOrder.create(product: create(:product_model))
    expect(delivery_order.order_no).to be_present
  end
end
