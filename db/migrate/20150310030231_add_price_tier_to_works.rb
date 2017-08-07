class AddPriceTierToWorks < ActiveRecord::Migration
  def change
    add_reference :works, :price_tier, index: true
  end
end
