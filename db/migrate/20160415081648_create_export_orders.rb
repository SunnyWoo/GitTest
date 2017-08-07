class CreateExportOrders < ActiveRecord::Migration
  def change
    create_table :export_orders do |t|
      t.string :file

      t.timestamps
    end
  end
end
