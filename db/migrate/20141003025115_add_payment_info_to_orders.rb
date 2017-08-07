class AddPaymentInfoToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :payment_info, :json, default: {}

    Order.all.each do |order|
      order.update(payment_info: {method: order.payment,
                                  payment_id: order.payment_id})
    end
  end

  class Order < ActiveRecord::Base
  end
end
