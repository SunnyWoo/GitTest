class AddStatusAndDownloadsCountToAssetPackage < ActiveRecord::Migration
  def change
    add_column :asset_packages, :status, :integer, default: 0
    add_column :asset_packages, :downloads_count, :integer, default: 0
    add_index :asset_packages, :downloads_count
  end
end
