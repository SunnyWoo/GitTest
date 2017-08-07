module Admin::PriceTiersHelper
  def options_for_price_tier_select
    currencies = [current_currency_code, 'TWD'].uniq
    PriceTier.ordered.map do |price_tier|
      prices = currencies.map do |currency|
        "#{render_price(price_tier.prices[currency], currency_code: currency)} (#{currency})"
      end.join(' ≈ ')
      ["Tier #{price_tier.tier} / #{prices}", price_tier.id]
    end
  end
end
