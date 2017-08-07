class CreateProductModelTranslation < ActiveRecord::Migration
  def up
    ProductModel.add_translation_fields! name: :string
    ProductModel.add_translation_fields! description: :text
  end

  def down
    remove_column :product_model_translations, :name
    remove_column :product_model_translations, :description
  end

  class ProductModel < ActiveRecord::Base
    translates :name, :description, :suffix
  end
end
