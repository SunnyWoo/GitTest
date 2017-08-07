class AddJidToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :jid, :string
  end
end
