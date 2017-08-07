class RemoveAssetPackageColumnStatus < ActiveRecord::Migration
  def change
    remove_column :asset_packages, :status
  end
end
