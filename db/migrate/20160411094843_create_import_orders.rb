class CreateImportOrders < ActiveRecord::Migration
  def change
    create_table :import_orders do |t|
      t.string :file
      t.string :aasm_state
      t.json :succeed
      t.json :failed

      t.timestamps
    end
  end
end
