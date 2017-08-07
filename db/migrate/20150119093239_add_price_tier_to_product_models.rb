class AddPriceTierToProductModels < ActiveRecord::Migration
  def change
    add_reference :product_models, :price_tier, index: true
  end
end
