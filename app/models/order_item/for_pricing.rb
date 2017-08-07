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

class OrderItem::ForPricing < ActiveType::Record[OrderItem]
  attr_accessor :coupon_discount
  def readonly?; true; end

  def adjustments
    super.rewhere(adjustable_type: 'OrderItem')
  end

  def notes
    super.rewhere(noteable_type: 'OrderItem')
  end
end
