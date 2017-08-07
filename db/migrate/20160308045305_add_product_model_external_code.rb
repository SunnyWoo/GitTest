class AddProductModelExternalCode < ActiveRecord::Migration
  def change
    add_column :product_models, :external_code, :string
  end
end
