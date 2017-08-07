class ChangeOrderMessageToText < ActiveRecord::Migration
  def change
    change_column :orders, :message, :text
    add_column :orders, :order_info, :json
  end
end
