# == Schema Information
#
# Table name: purchase_product_references
#
#  id          :integer          not null, primary key
#  product_id  :integer
#  category_id :integer
#  b2c_count   :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Purchase::ProductReference < ActiveRecord::Base
  extend Guanyi::MonthlyOrders
  include RedisCacheable

  belongs_to :product, class_name: 'ProductModel'
  belongs_to :category, class_name: 'Purchase::Category'

  value :price

  class << self
    def collect_product_b2c_count
      clear_history

      orders.includes(order_items: :itemable).find_each do |order|
        order.order_items.each do |order_item|
          increment_b2c_count(order_item)
        end
      end
    end

    def increment_b2c_count(order_item)
      find_by!(product_id: order_item.itemable.model_id).increment!(:b2c_count, order_item.quantity)
    rescue => e
      SlackNotifier.send_msg("PurchaseCalculateError: #{e}, OrderItem: #{order_item.id}")
    end

    def clear_history
      Purchase::ProductReference.all.find_each do |pr|
        pr.update_attributes(b2c_count: 0, price: nil)
      end
    end
  end

  def purchase_price
    return price.value if price.value.to_b
    self.price = category.purchase_price.to_s
  end
end
