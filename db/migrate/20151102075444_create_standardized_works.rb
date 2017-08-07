class CreateStandardizedWorks < ActiveRecord::Migration
  def change
    create_table :standardized_works do |t|
      t.string :uuid
      t.belongs_to :user, polymorphic: true, index: true
      t.belongs_to :model, index: true
      t.string :name
      t.string :slug
      t.string :aasm_state
      t.belongs_to :price_tier, index: true
      t.boolean :featured, null: false, default: false
      t.string :print_image
      t.json :image_meta, null: false, default: {}

      t.timestamps
      t.datetime :deleted_at
    end

    add_index :standardized_works, :slug, unique: true
    add_index :standardized_works, :uuid, unique: true
    add_index :standardized_works, :aasm_state
  end
end
