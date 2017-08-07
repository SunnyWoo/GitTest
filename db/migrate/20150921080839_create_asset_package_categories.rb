class CreateAssetPackageCategories < ActiveRecord::Migration
  def up
    create_table :asset_package_categories do |t|
      t.string :name
      t.boolean :available, null: false, default: false
      t.timestamps
    end
    AssetPackageCategory.create_translation_table! name: :string
  end

  def down
    drop_table :asset_package_categories
    AssetPackageCategory.drop_translation_table!
  end
end
