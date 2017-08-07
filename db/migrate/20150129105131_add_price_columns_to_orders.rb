class AddPriceColumnsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :subtotal, :decimal, precision: 8, scale: 2
    add_column :orders, :discount, :decimal, precision: 8, scale: 2
    add_column :orders, :shipping_fee, :decimal, precision: 8, scale: 2
  end
end
