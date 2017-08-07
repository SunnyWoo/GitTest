class CreateLogisticsSuppliers < ActiveRecord::Migration
  def change
    create_table :logistics_suppliers do |t|
      t.string :name
      t.timestamps
    end
  end
end
