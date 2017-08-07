class AddDiscountToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :discount, :decimal, precision: 8, scale: 2

    OrderItem.reset_column_information

    Order.where.not(embedded_coupon: nil).find_each do |order|
      if order.embedded_coupon.apply_target == 'once'
        apply_count_limit = 1
      elsif order.embedded_coupon.apply_target == 'per_item'
        apply_count_limit = -1
      end
      update_embedded_coupon = { 'apply_count_limit' => apply_count_limit, 'base_price_type' => 'special' }
      embedded_coupon = EmbeddedCoupon.new(order.embedded_coupon.as_json.merge(update_embedded_coupon))
      order.update_column(:embedded_coupon, embedded_coupon.as_json)
      price_calculator = PriceCalculator.new(order.reload, order.currency)
      if !order.order_items.any?{ |item| item.itemable.blank? } && order.embedded_coupon.pass_condition?(price_calculator, order.currency)
        price_calculator.discount
        price_calculator.order.order_items.each(&:save)
      end
    end
  end
end
