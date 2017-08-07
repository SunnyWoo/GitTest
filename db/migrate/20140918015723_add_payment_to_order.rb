class AddPaymentToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :payment, :integer
    add_column :orders , :order_data, :hstore
    add_index :orders, :order_data

    Order.find_each do |order|
      order.update(payment: 'paypal')
    end
  end
end
