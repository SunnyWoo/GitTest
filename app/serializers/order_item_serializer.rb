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

# NOTE: not used in v3 api, remove me later
class OrderItemSerializer < ActiveModel::Serializer
  attributes :quantity, :work_id, :work_uuid, :price

  def work_id
    object.itemable_uuid
  end

  def work_uuid
    object.itemable_uuid
  end

  def price
    object.price_in_currency(object.order.currency)
  end
end
