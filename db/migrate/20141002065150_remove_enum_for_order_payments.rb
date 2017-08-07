class RemoveEnumForOrderPayments < ActiveRecord::Migration
  ORDER_PAYMENTS = {
    'paypal'           => 0,
    'cash_on_delivery' => 1
  }

  def up
    change_column :orders, :payment, :string

    ORDER_PAYMENTS.each do |method, id|
      Order.where(payment: id.to_s).update_all(payment: method)
    end
  end

  def down
    ORDER_PAYMENTS.each do |method, id|
      Order.where(payment: method).update_all(payment: id.to_s)
    end

    change_column :orders, :payment, 'integer USING CAST(payment AS integer)'
  end

  class Order < ActiveRecord::Base
  end
end
