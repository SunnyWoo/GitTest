class AddColumnDesignerTypeToWorkSet < ActiveRecord::Migration
  def up
    add_column :work_sets, :designer_type, :string
    add_index :work_sets, [:designer_id, :designer_type]

    WorkSet.update_all designer_type: 'Designer'
  end

  def down
    remove_column :work_sets, :designer_type
    remove_index :work_sets, [:designer_id, :designer_type]
  end
end
