class AddOrderItemsSellingPrices < ActiveRecord::Migration
  def change
    add_column :order_items, :selling_prices, :json
  end
end
