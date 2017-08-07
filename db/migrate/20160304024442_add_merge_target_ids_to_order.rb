class AddMergeTargetIdsToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :merge_target_ids, :integer, array: true, default: []
  end
end
