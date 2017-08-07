class AddInvoiceInfoToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :invoice_info, :json
  end
end
