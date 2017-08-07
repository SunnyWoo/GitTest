class AddPackgeIdToWaybillRoute < ActiveRecord::Migration
  def change
    add_column :waybill_routes, :package_id, :integer
    add_index :waybill_routes, :package_id
  end
end
