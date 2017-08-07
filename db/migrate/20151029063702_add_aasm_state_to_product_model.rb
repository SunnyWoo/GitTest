class AddAasmStateToProductModel < ActiveRecord::Migration
  def change
    add_column :product_models, :aasm_state, :string
    ProductModel.update_all(aasm_state: 'customer')
  end
end
