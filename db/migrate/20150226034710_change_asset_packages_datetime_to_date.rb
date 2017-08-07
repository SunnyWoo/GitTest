class ChangeAssetPackagesDatetimeToDate < ActiveRecord::Migration
  def change
    change_column :asset_packages, :begin_at, :date
    change_column :asset_packages, :end_at, :date
  end
end
