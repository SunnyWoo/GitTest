class CreateBatchFlows < ActiveRecord::Migration
  def change
    create_table :batch_flows do |t|
      t.string :aasm_state
      t.belongs_to :factory, index: true
      t.integer :product_model_ids, array: true, default: []
      t.integer :print_item_ids, array: true, default: []
      t.string :batch_no
      t.timestamps
    end
    add_index :batch_flows, [:factory_id, :batch_no], unique: true
  end
end
