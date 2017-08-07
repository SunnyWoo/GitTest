module Admin::PromotionsHelper
  def render_price_with_tooltip(price, option = {})
    case price
    when String
      price
    when Price
      option[:label] ||= 'warning'
      prices = price.to_h.map { |currency, value| render_price(value, currency_code: currency) }.join("\n")
      content = render_price(price.value, currency_code: price.currency)
      title = simple_format prices
      content_tag(:span, content, class: "label label-#{option[:label]}", data: { rel: 'tooltip', html: true, placement: 'right', title: title })
    else
      'N/A'
    end
  end

  def render_price_tier(price_tier)
    price = Price.new(price_tier.prices)
    render_price_with_tooltip(price)
  end

  def render_price_tier_toolip(price_tier)
    prices = price_tier.prices.map { |currency, value| render_price(value, currency_code: currency) }.join("\n")
    simple_format prices
  end

  def render_tooltip_price_tier(price_tier)
    prices = price_tier.prices.to_a.map { |p| p.join(' ') }.join('<br />')
    info = [prices, price_tier.price_in_currency(Region.default_currency)]
    "<span class='label label-warning' data-rel='tooltip' data-html='true' data-placement='right' title='#{info[0]}'>#{info[1]}</span>".html_safe
  end

  def render_discount_formula(formula)
    options = if formula.percentage?
                { percentage: "<em>#{formula.percentage * 100}%</em>" }
              else
                { binded_price: render_price_with_tooltip(formula.binded_price) }
              end
    I18n.t("discount_formula.#{formula.type}.humanize", options)
  rescue ActiveRecord::RecordNotFound => e
    e.message
  end
end
