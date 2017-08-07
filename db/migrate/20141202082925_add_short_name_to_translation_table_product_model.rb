class AddShortNameToTranslationTableProductModel < ActiveRecord::Migration
  def up
    ProductModel.add_translation_fields! short_name: :string
  end

  def down
    remove_column :product_model_translations, :short_name, :string
  end
end
