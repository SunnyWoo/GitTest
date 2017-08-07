class AddDeleteAtToWork < ActiveRecord::Migration
  def change
    add_column :works, :deleted_at, :datetime
    add_index :works, :deleted_at
  end
end
