class Pricing::ItemableDecorator < ApplicationDecorator
  delegate_all

  def cache_key
    [source.cache_key, active_promotions.first.try(:cache_key)]
  end

  def original_prices
    [promotion_special_price, promotion_original_price].max
  end

  def prices
    source.promotion_special_price
  end
end
