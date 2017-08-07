class AddShippingFeeDiscountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shipping_fee_discount, :decimal, precision: 8, scale: 2, default: 0.0
  end
end
