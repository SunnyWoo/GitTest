# == Schema Information
#
# Table name: promotions
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  description     :text
#  type            :string(255)      not null
#  aasm_state      :integer
#  rule            :integer
#  rule_parameters :json
#  targets         :integer
#  begins_at       :datetime
#  ends_at         :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  level           :integer
#

class Promotion::ForProductModel < Promotion
  include ActsAsItemPromotion
  include ActsAsUnifiedDiscountPromotion

  has_many :references, class_name: PromotionReference.to_s, foreign_key: :promotion_id, dependent: :destroy
  has_many :products, through: :references, source: :promotable, source_type: "ProductModel"

  def applicable?(item)
    item.itemable.current_promotion == self
  end

  def effecting_orders
    OrderQuery.new(Order.pending).by_products(products).execute
  end
end
