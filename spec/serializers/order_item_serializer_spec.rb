# == Schema Information
#
# Table name: order_items
#
#  id               :integer          not null, primary key
#  order_id         :integer
#  itemable_id      :integer
#  itemable_type    :string(255)
#  quantity         :integer
#  created_at       :datetime
#  updated_at       :datetime
#  timestamp_no     :integer
#  print_at         :datetime
#  aasm_state       :string(255)
#  pdf              :string(255)
#  prices           :json
#  original_prices  :json
#  discount         :decimal(8, 2)
#  remote_id        :integer
#  delivered        :boolean          default(FALSE)
#  deliver_complete :boolean          default(FALSE)
#  remote_info      :json
#  selling_prices   :json
#

require 'spec_helper'

describe OrderItemSerializer do
  it 'works' do
    order = create(:order)
    order.reload
    order_item = order.order_items.first
    json = JSON.parse(OrderItemSerializer.new(order_item).to_json)
    expect(json).to eq('order_item' => {
                         'quantity' => order_item.quantity,
                         'work_id' => order_item.itemable.uuid,
                         'work_uuid' => order_item.itemable.uuid,
                         'price' => order_item.price_in_currency(order.currency)
                       })
  end
end
