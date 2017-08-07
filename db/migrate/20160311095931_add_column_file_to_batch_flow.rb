class AddColumnFileToBatchFlow < ActiveRecord::Migration
  def change
    add_column :batch_flows, :file, :string
  end
end
