class AddCategoryIdToAssetPackage < ActiveRecord::Migration
  def change
    add_column :asset_packages, :category_id, :integer
    add_index :asset_packages, :category_id
  end
end
