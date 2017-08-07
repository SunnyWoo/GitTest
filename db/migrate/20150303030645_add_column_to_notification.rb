class AddColumnToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :filter, :json
    add_column :notifications, :delivery_at, :datetime
    add_column :notifications, :deep_link, :string
  end
end
