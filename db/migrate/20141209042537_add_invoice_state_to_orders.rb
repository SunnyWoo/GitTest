class AddInvoiceStateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :invoice_state, :integer, default: 0
    add_index  :orders, :invoice_state
  end
end
