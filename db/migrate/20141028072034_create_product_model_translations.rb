class CreateProductModelTranslations < ActiveRecord::Migration
  def up
    ProductModel.create_translation_table!({
      suffix: :string
    }, {
      migrate_data: true
    })
  end

  def down
    ProductModel.drop_translation_table! migrate_data: true
  end

  class ProductModel < ActiveRecord::Base
    translates :suffix
  end
end
