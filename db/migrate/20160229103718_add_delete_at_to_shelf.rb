class AddDeleteAtToShelf < ActiveRecord::Migration
  def change
    add_column :shelves, :deleted_at, :datetime
  end
end
