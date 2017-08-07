module Admin::CouponsHelper
  def collection_for_coupon_title_with_code
    result = Coupon.all.map { |c| ["#{c.title} - #{c.code}", c.code] }
    result.unshift [' ', nil]
  end

  def coupon_usage_count(coupon)
    used = coupon.is_used? ? t('shared.wordings.used') : t('shared.wordings.not_used')
    "#{used} (#{coupon.usage_count}/#{coupon.usage_count_limit})"
  end

  def link_to_edit_coupon_for_order(order)
    coupon_price = render_price(order.coupon_price, currency_code: order.currency)
    coupon = order.coupon
    parent_coupon = coupon.parent || coupon
    link_to "#{order.coupon.title}(-#{coupon_price})", edit_admin_coupon_path(parent_coupon), target: '_blank'
  end

  def render_coupon_code(coupon)
    coupon.children_count > 0 ? 'Batch Generate' : coupon.code
  end

  def render_off_price(coupon)
    msg = []
    case coupon.discount_type
    when 'fixed'
      price = number_to_currency(coupon.price('TWD'))
      msg << "#{price} off #{render_condition(coupon)}"
    when 'percentage'
      percentage = to_safe_decimal(coupon.percentage)
      msg << "#{(percentage * 100).ceil}% off #{render_condition(coupon)}"
    when 'pay'
      price = number_to_currency(coupon.price('TWD'))
      msg << "Order price = #{price}"
      msg << render_condition(coupon)
    when 'none'
      msg << 'None'
    end
    msg.join(', ')
  end

  def render_condition(coupon)
    case coupon.condition
    when 'none'
      'all orders'
    when 'simple', 'rules'
      coupon.coupon_rules.map { |rule| render_coupon_rule_condition(rule) }.join(', ')
    end
  end

  def render_coupon_rule_condition(coupon_rule)
    case coupon_rule.condition
    when 'threshold'
      price = number_to_currency(coupon_rule.threshold.prices['TWD'])
      "order over #{price}"
    when 'include_product_models'
      product_models = ProductModel.find(coupon_rule.product_model_ids).map(&:name).sort.join(',')
      "order product model have (#{product_models})"
    when 'include_designers'
      designers = Designer.find(coupon_rule.designer_ids).map(&:display_name).join(',')
      "order designer have (#{designers})"
    when 'include_designers_models'
      product_models = ProductModel.find(coupon_rule.product_model_ids).map(&:name).join(',')
      designers = Designer.find(coupon_rule.designer_ids).map(&:display_name).join(',')
      "order designer have (#{designers}) and  product model have(#{product_models})"
    when 'include_works'
      works = coupon_rule.work_gids.map do |gid|
                work = GlobalID::Locator.locate(gid)
                "[#{work.class.name} ID:#{work.id} Name:#{work.name}]"
              end.join(', ')
      "order items have (#{works})"
    when 'include_product_categories'
      if coupon_rule.product_category_ids.include?(-1)
        "order include any product category"
      else
        categories = ProductCategory.find(coupon_rule.product_category_ids).map(&:name).sort.join(',')
        "order product category have (#{categories})"
      end
    when 'include_bdevent'
      if coupon_rule.bdevent
        bdevent = coupon_rule.bdevent
        "For Bdevent #{bdevent.title} #{bdevent.starts_at.strftime('%F %T')} ~ #{bdevent.ends_at.strftime('%F %T')}"
      end
    end
  end

  def to_safe_decimal(input)
    if input.nil? || input.try(:infinite?) || input.try(:nan?)
      BigDecimal.new('0.0')
    else
      input
    end
  end

  def coupon_status_text(is_used)
    is_used ? t('js.coupon.index.used') : t('js.coupon.index.unused')
  end
end
