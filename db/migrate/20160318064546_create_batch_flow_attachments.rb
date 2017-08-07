class CreateBatchFlowAttachments < ActiveRecord::Migration
  def change
    create_table :batch_flow_attachments do |t|
      t.integer :batch_flow_id, null: false
      t.string :name, null: false
      t.string :file, null: false
      t.timestamps
    end

    add_index :batch_flow_attachments, :batch_flow_id

    remove_column :batch_flows, :file
  end
end
