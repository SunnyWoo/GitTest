class AddEnableScheduleToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :enable_schedule, :boolean, default: true
    add_column :print_items, :enable_schedule, :boolean, default: true
  end
end
