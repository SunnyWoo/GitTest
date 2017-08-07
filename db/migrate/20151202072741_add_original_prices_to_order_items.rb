class AddOriginalPricesToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :original_prices, :json

    OrderItem.find_each do |item|
      item.update_column(:original_prices, item.itemable.try(:original_prices))
    end
  end
  class OrderItem < ActiveRecord::Base
    belongs_to :itemable, -> { try(:with_deleted) || all }, polymorphic: true
  end
end
