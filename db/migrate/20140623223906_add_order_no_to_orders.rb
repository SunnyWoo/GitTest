class AddOrderNoToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_no, :string
    add_index :orders, :order_no
  end
end
