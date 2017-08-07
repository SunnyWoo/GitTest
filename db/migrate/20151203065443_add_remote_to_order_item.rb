class AddRemoteToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :remote_id, :integer
    add_column :order_items, :delivered, :boolean, default: false
    add_column :order_items, :deliver_complete, :boolean, default: false
    add_column :order_items, :remote_info, :json, default: {}
  end
end
