class AddInvoiceToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :watching, :boolean, default: false
    add_column :orders, :invoice_required, :boolean
  end
end
