class CreateArchivedStandardizedWorks < ActiveRecord::Migration
  def change
    create_table :archived_standardized_works do |t|
      t.string :uuid
      t.string :slug
      t.belongs_to :original_work, index: true
      t.belongs_to :user, index: true, polymorphic: true
      t.belongs_to :model, index: true
      t.string :name
      t.belongs_to :price_tier, index: true
      t.boolean :featured
      t.string :print_image
      t.json :image_meta, null: false, default: {}

      t.timestamps
    end

    add_index :archived_standardized_works, :slug, unique: true
  end
end
