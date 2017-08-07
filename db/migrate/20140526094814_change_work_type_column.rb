class ChangeWorkTypeColumn < ActiveRecord::Migration
  def change
    remove_column :works, :work_type
    add_column :works, :work_type, :integer, default: 1
  end
end
