class CreateAssetPackages < ActiveRecord::Migration
  def up
    create_table :asset_packages do |t|
      t.belongs_to :designer, index: true
      t.string :icon
      t.boolean :available, null: false, default: false
      t.datetime :begin_at
      t.datetime :end_at
      t.string :countries, array: true, default: []
      t.integer :position
      t.json :image_meta

      t.timestamps
    end

    AssetPackage.create_translation_table!(name: :string, description: :text)
  end

  def down
    AssetPackage.drop_translation_table!

    drop_table :asset_packages
  end

  class AssetPackage < ActiveRecord::Base
    translates :name, :description
  end
end
