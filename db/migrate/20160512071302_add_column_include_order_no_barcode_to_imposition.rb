class AddColumnIncludeOrderNoBarcodeToImposition < ActiveRecord::Migration
  def change
    add_column :impositions, :include_order_no_barcode, :boolean, default: false
  end
end
