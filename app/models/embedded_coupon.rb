class EmbeddedCoupon
  include CouponDiscountCalculator

  attr_reader :id, :title, :code, :prices, :condition, :discount_type, :percentage,
              :product_model_ids, :product_category_ids, :apply_target, :begin_at,
              :expired_at, :designer_ids, :work_gids, :base_price_type, :apply_count_limit,
              :bdevent_id, :threshold_prices, :is_free_shipping, :is_not_include_promotion, :coupon_rules

  def initialize(hash)
    @id                        = hash['id']
    @title                     = hash['title']
    @code                      = hash['code']
    @prices                    = hash['prices']
    @discount_type             = hash['discount_type']
    @percentage                = hash['percentage']
    @condition                 = hash['condition']
    @threshold_prices          = hash['threshold_prices']
    @product_model_ids         = hash['product_model_ids']
    @product_category_ids      = hash['product_category_ids']
    @designer_ids              = hash['designer_ids']
    @apply_target              = hash['apply_target']
    @begin_at                  = parse_date(hash['begin_at'])
    @expired_at                = parse_date(hash['expired_at'])
    @work_gids                 = hash['work_gids']
    @base_price_type           = hash['base_price_type']
    @apply_count_limit         = hash['apply_count_limit']
    @bdevent_id                = hash['bdevent_id']
    @is_free_shipping          = hash['is_free_shipping']
    @is_not_include_promotion  = hash['is_not_include_promotion']
    @coupon_rules              = hash['coupon_rules'].to_a.map { |rule| EmbeddedCouponRule.new(rule) }
  end

  def parse_date(date)
    if date.present?
      Date.parse(date)
    else
      Date.today
    end
  end

  def price(currency)
    @prices[currency]
  end

  def percentage
    BigDecimal.new(@percentage.to_s)
  end

  def self.dump(object)
    object.as_json
  end

  def self.load(hash)
    EmbeddedCoupon.new(hash.with_indifferent_access) if hash
  end
end
