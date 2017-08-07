class AddColumnsWorkIdsToBdeventRedeems < ActiveRecord::Migration
  def change
    add_column :bdevent_redeems, :work_ids, :integer, array: true, default: []
  end
end
