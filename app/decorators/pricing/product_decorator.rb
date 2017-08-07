class Pricing::ProductDecorator < Draper::Decorator
  delegate_all

  def cache_key
    [source, active_promotions.first]
  end

  def prices
    [promotion_original_price, promotion_special_price].max
  end

  def customized_special_prices
    promotion_special_price
  end
end
