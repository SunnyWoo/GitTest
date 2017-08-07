class AddPaymentIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :payment_id, :string
  end
end
