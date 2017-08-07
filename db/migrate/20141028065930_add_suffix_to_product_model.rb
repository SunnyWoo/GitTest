class AddSuffixToProductModel < ActiveRecord::Migration
  def change
    add_column :product_models, :suffix, :string
  end
end
