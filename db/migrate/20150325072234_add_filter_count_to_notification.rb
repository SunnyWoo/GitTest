class AddFilterCountToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :filter_count, :integer
  end
end
