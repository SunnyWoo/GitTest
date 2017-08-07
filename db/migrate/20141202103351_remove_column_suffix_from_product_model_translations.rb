class RemoveColumnSuffixFromProductModelTranslations < ActiveRecord::Migration
  def change
    remove_column :product_model_translations, :suffix, :string
  end
end
