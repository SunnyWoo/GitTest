class AddShippingReceiptToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :shipping_receipt, :string
  end
end
