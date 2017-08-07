class AddCodeToProductModel < ActiveRecord::Migration
  def change
    add_column :product_models, :code, :string
  end
end
