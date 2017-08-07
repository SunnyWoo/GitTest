class CreateStoreComponents < ActiveRecord::Migration
  def change
    create_table :store_components do |t|
      t.belongs_to :store, index: true
      t.string :key
      t.string :image
      t.integer :position
      t.text :content
      t.timestamps
    end
  end
end
