class AddPdfToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :pdf, :string
  end
end
