class AddDeletedAtToShelfMaterial < ActiveRecord::Migration
  def change
    add_column :shelf_materials, :deleted_at, :datetime
  end
end
