class AddColumnDownloadsTotalPackeagesCountToAssetPackageCategory < ActiveRecord::Migration
  def change
    add_column :asset_package_categories, :packages_count, :integer, default: 0
    add_column :asset_package_categories, :downloads_count, :integer, default: 0

    add_index :asset_package_categories, :downloads_count
    add_index :asset_package_categories, :packages_count
  end
end
