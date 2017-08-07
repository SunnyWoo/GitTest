class AddCustomizedSpecialPriceTierIdToProductModels < ActiveRecord::Migration
  def change
    add_reference :product_models, :customized_special_price_tier, index: true
  end
end
