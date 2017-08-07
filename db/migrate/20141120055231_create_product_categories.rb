class CreateProductCategories < ActiveRecord::Migration
  def up
    create_table :product_categories do |t|
      t.string :key
      t.boolean :available, default: false, null: false

      t.timestamps
    end

    add_index :product_categories, :key, unique: true

    add_column :product_models, :category_id, :integer
    add_index :product_models, :category_id

    ProductCategory.create_translation_table!(name: :string)

    category = ProductCategory.create(key: 'default')
    ProductModel.update_all(category_id: category.id)
  end

  def down
    ProductCategory.drop_translation_table!

    remove_index :product_models, :category_id
    remove_column :product_models, :category_id

    remove_index :product_categories, :key

    drop_table :product_categories
  end

  class ProductCategory < ActiveRecord::Base
    translates :name
  end

  class ProductModel < ActiveRecord::Base
  end
end
