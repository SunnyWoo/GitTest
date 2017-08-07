class RemoveColumnSuffixFromProductModel < ActiveRecord::Migration
  def change
    remove_column :product_models, :suffix, :string
  end
end
