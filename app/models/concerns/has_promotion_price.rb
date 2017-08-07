module HasPromotionPrice
  extend ActiveSupport::Concern

  included do
    after_save :flush_cached_promotion_prices
  end

  def build_promotion_adjustment(order_item)
    return unless current_promotion
    current_promotion.build_apply_adjustment(order_item)
  end

  def promotion_special_price
    Rails.cache.fetch(promotion_price_cache_key) || cache_promotion_price
  end

  def promotion_discount_price
    _special_price - promotion_special_price
  end

  def current_promotion
    Rails.cache.fetch(promotion_cache_key) || cache_current_promotion
  end

  def promotion_original_price
    _original_price
  end

  def cache_promotion_price
    promotion, price = fetch_current_promotion_and_price
    cache_key = promotion_price_cache_key

    if promotion
      Rails.cache.write(cache_key, price, expired_at: promotion.ends_at) if cache_key
      price
    else
      Rails.cache.write(cache_key, _special_price, expired_at: Time.zone.now.end_of_day) if cache_key
      _special_price
    end
  end

  def cache_current_promotion
    promotion, _price = fetch_current_promotion_and_price
    cache_key = promotion_cache_key

    if promotion
      Rails.cache.write(cache_key, promotion, expired_at: promotion.ends_at) if cache_key
      promotion
    else
      Rails.cache.write(cache_key, nil, expired_at: Time.zone.now.end_of_day) if cache_key
      nil
    end
  end

  def active_promotions
    raise NoMethodError, 'subclass responsibility'
  end

  def flush_cached_promotion_prices
    return unless id
    Rails.cache.delete(promotion_cache_key)
    Rails.cache.delete(promotion_price_cache_key)
  end

  private

  def fetch_current_promotion_and_price
    active_promotions.map { |p|
      [p, p.fetch_promotion_price(self)]
    }.compact.sort_by(&:last).first
  end

  def _special_price
    Price.new(special_prices)
  end

  def _original_price
    Price.new(original_prices)
  end

  def promotion_cache_key
    "#{self.class.name}_#{id}_PROMOTION_CACHE".upcase if id
  end

  def promotion_price_cache_key
    "#{self.class.name}_#{id}_PROMOTION_PRICE_CACHE".upcase if id
  end
end
