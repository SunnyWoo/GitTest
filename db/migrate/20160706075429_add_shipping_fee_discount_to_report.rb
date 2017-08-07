class AddShippingFeeDiscountToReport < ActiveRecord::Migration
  def change
    add_column :reports, :shipping_fee_discount, :integer
  end
end
