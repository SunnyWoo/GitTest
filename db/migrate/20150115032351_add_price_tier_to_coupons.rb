class AddPriceTierToCoupons < ActiveRecord::Migration
  def change
    add_reference :coupons, :price_tier, index: true
  end
end
