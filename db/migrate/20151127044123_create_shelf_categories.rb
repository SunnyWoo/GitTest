class CreateShelfCategories < ActiveRecord::Migration
  def change
    create_table :shelf_categories do |t|
      t.integer :factory_id
      t.string :name, null: false
      t.string :description

      t.timestamps
    end

    add_index :shelf_categories, :factory_id
    add_index :shelf_categories, :name, unique: true
    add_index :shelf_categories, [:name, :factory_id], unique: true
  end
end
