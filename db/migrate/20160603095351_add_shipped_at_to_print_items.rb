class AddShippedAtToPrintItems < ActiveRecord::Migration
  def change
    add_column :print_items, :shipped_at, :datetime
    add_column :print_histories, :shipped_at, :datetime
  end
end
