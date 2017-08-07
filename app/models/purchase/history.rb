# == Schema Information
#
# Table name: purchase_histories
#
#  id            :integer          not null, primary key
#  duration_id   :integer
#  product_id    :integer
#  category_name :string(255)
#  b2c_count     :integer
#  price         :float
#  price_tiers   :json
#  created_at    :datetime
#  updated_at    :datetime
#

class Purchase::History < ActiveRecord::Base
  belongs_to :duration
  belongs_to :product, class_name: 'ProductModel'
  serialize :price_tiers, PriceTierHistory::ArraySerializer

  # 采购入库单建立之后 把上月的记录保存
  def self.create_histories
    ActiveRecord::Base.transaction do
      prev_month = Time.zone.now.prev_month
      duration = Purchase::Duration.create!(year: prev_month.year, month: prev_month.month)

      Purchase::ProductReference.includes(category: :price_tiers).all.find_each do |product_reference|
        create!(
          duration_id: duration.id,
          product_id: product_reference.product_id,
          category_name: product_reference.category.name,
          b2c_count: product_reference.b2c_count,
          price: product_reference.purchase_price,
          price_tiers: product_reference.category.simplify_price_tiers
        )
      end
    end
  end
end
