class EmbeddedCouponRule
  attr_reader :id, :condition, :product_model_ids, :product_category_ids,
              :designer_ids, :work_gids, :quantity, :threshold_prices, :coupon_rules,
              :bdevent_id

  def initialize(hash)
    @id                   = hash['id']
    @condition            = hash['condition']
    @threshold_prices     = hash['threshold_prices']
    @product_model_ids    = hash['product_model_ids']
    @product_category_ids = hash['product_category_ids']
    @designer_ids         = hash['designer_ids']
    @work_gids            = hash['work_gids']
    @bdevent_id           = hash['bdevent_id']
    @quantity             = hash['quantity']
  end

  def self.dump(object)
    object.as_json
  end

  def self.load(hash)
    EmbeddedCoupon.new(hash.with_indifferent_access) if hash
  end
end
