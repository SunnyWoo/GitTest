class AddSublimatedAtToPrintItems < ActiveRecord::Migration
  def change
    add_column :print_items, :sublimated_at, :datetime
  end
end
