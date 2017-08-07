class Admin::PromotionDecorator < ApplicationDecorator
  delegate_all

  STATE_CSS_MAPPING = {
    "pending" => 'warning',
    "ready" => "info",
    "started" => "success",
    "ended" => "inverse"
  }.freeze

  def type_name
    I18n.t("promotions.type_options.#{type.demodulize.underscore}")
  end

  def state
    aasm.human_state
  end

  def state_css
    STATE_CSS_MAPPING[aasm_state]
  end

  def duration_percentage
    return 50 unless ends_at && begins_at
    bi = begins_at.to_i
    ei = ends_at.to_i
    ((Time.zone.now.to_i - bi) * 100 / (ei - bi)).round
  end

  def content
    return unset_content unless conditioned?
    case type.demodulize.underscore
    when 'for_itemable_price'
      I18n.t("promotions.content.for_itemable_price", promotables: promotable_names.to_sentence)
    when 'for_product_model', 'for_product_category'
      I18n.t("promotions.content.unified_discount", promotables: promotable_names.to_sentence, discount: discount_description)
    when 'for_shipping_fee'
      I18n.t("promotions.content.for_shipping_fee", rules: rules_description)
    when 'for_order_price'
      I18n.t("promotions.content.for_order_price", rules: rules_description, discount: discount_description)
    else
      "Unknown"
    end
  end

  def unset_content
    I18n.t("promotions.content.unset")
  end

  def begins_at_from_now
    return state if started?
    return '' if begins_at < Time.zone.now
    h.time_ago_in_words begins_at, include_seconds: true
  end

  def ends_at_from_now
    return state if ended?
    return I18n.t('promotions.messages.unlimited_duration') if ends_at.blank?
    return '' if ends_at < Time.zone.now
    h.time_ago_in_words ends_at, include_seconds: true
  end

  def simple_discount?
    source.is_a?(Promotion::ForItemablePrice)
  end

  def shipping_fee_discount?
    source.is_a?(Promotion::ForShippingFee)
  end

  def promotable_names
    references.map { |pr| pr.promotable.name }
  end

  def references
    @references ||= source.references.includes(:promotable)
  end

  def discount_description
    h.render_discount_formula(discount_formula)
  end

  def rules_description
    rules.map do |rule|
      args = {}
      if rule.threshold? && rule.threshold
        price = Price.new(rule.threshold.prices)
        args[:price] = h.render_price_with_tooltip(price)
      end
      I18n.t("promotions.rule.condition.#{rule.condition}", args)
    end.to_sentence
  end
end
