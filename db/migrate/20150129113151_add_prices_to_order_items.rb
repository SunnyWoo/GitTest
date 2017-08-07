class AddPricesToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :prices, :json
  end
end
