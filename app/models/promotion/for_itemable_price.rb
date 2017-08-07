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

class Promotion::ForItemablePrice < Promotion
  include ActsAsItemPromotion

  has_many :references, autosave: true, class_name: PromotionReference.to_s, foreign_key: :promotion_id, dependent: :destroy
  has_many :product_categories, through: :references, source: :promotable, source_type: "ProductCategory"
  has_many :products, through: :references, source: :promotable, source_type: "ProductModel"
  has_many :standardized_works, through: :references, source: :promotable, source_type: "StandardizedWork"

  def effecting_orders
    ids = []
    ids += OrderQuery.new(Order.pending).by_categories(product_categories).execute.pluck(:id) if product_categories.any?
    ids += OrderQuery.new(Order.pending).by_products(products).execute.pluck(:id) if products.any?
    ids += OrderQuery.new(Order.pending).by_standardized_works(standardized_works).execute.pluck(:id) if standardized_works.any?
    Order.where(id: ids)
  end

  def fetch_promotion_price(promotable)
    promotables = case promotable
                  when ProductModel
                    [promotable, promotable.category]
                  when StandardizedWork
                    [promotable, promotable.product, promotable.product.category]
                  when Work, ArchivedWork
                    [promotable.product, promotable.product.category]
                  when ArchivedStandardizedWork
                    [promotable.original_work, promotable.product, promotable.product.category]
                  end

    promotions = references.select { |x| x.promotable.in?(promotables) }
    price = promotions.map { |x| Price.new(x.price_tier.try(:prices)) }.sort.first

    price || Price.new(promotable.special_prices)
  end

  def has_included?(promotable)
    references.any? do |r|
      r.promotable_type == promotable.class.name &&
        r.promotable_id == promotable.id
    end
  end

  def conditioned?
    references.any?
  end
end
