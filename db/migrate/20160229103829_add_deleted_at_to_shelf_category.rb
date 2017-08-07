class AddDeletedAtToShelfCategory < ActiveRecord::Migration
  def change
    add_column :shelf_categories, :deleted_at, :datetime
  end
end
