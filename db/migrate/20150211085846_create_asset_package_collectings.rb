class CreateAssetPackageCollectings < ActiveRecord::Migration
  def change
    create_table :asset_package_collectings do |t|
      t.belongs_to :user, index: true
      t.belongs_to :asset_package, index: true

      t.timestamps
    end
  end
end
