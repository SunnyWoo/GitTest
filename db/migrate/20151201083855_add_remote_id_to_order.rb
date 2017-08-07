class AddRemoteIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :remote_id, :integer
    add_column :orders, :delivered_at, :datetime
    add_column :orders, :deliver_complete, :boolean, default: false
    add_column :orders, :remote_info, :json, default: {}
  end
end
