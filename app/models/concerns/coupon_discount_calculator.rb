module CouponDiscountCalculator
  # 計算折價
  # 只有［总额超过］一个condition的计算方法和［整笔订单］一样

  def discount(price_calculator, target_currency)
    if pass_condition?(price_calculator, target_currency)
      case discount_type
      when 'fixed'
        if condition == 'shipping_fee'
          # 對運費折價
          discount_for_shipping_fee(price_calculator, target_currency)
        elsif condition.in?(%w(rules simple)) && !condition_threshold_only
          per_item_discount(price_calculator, target_currency)
        else
          # 對訂單折價
          order_discount(:fixed_discount, price: base_price(price_calculator, target_currency), target_currency: target_currency, price_calculator: price_calculator)
        end
      when 'percentage'
        if condition == 'shipping_fee'
          # 對運費折價
          discount_for_shipping_fee(price_calculator, target_currency)
        elsif condition.in?(%w(rules simple)) && !condition_threshold_only
          per_item_discount(price_calculator, target_currency)
        else
          # 對訂單折價
          order_discount(:percentage_discount, price: base_price(price_calculator, target_currency), target_currency: target_currency, price_calculator: price_calculator)
        end
      when 'pay'
        if condition == 'shipping_fee'
          # 對運費折價
          discount_for_shipping_fee(price_calculator, target_currency)
        elsif condition.in?(%w(rules simple)) && !condition_threshold_only
          per_item_discount(price_calculator, target_currency)
        else
          # 對訂單折價
          order_discount(:pay_discount, price: base_price(price_calculator, target_currency), target_currency: target_currency, price_calculator: price_calculator)
        end
      when 'none'
        0
      end
    else
      raise CannotUseCouponError
    end
  end

  # 只有［总额超过］一个condition
  def condition_threshold_only
    coupon_rules.map(&:condition) == ['threshold']
  end

  # 判斷是否可使用 coupon
  def pass_condition?(price_calculator, target_currency)
    case condition
    when 'none'
      true
    when 'shipping_fee'
      price_calculator.shipping(target_currency) > 0
    when 'rules', 'simple'
      pass_rules?(price_calculator, target_currency)
    end
  end

  def pass_rules?(price_calculator, target_currency)
    items = price_calculator.order.order_items
    coupon_rules.all? { |rule| pass_rule_condition?(items, rule, price_calculator, target_currency) }
  end

  def pass_rule_condition?(items, rule, price_calculator, target_currency, check_item = false)
    case rule.condition
    when 'threshold'
      base_price(price_calculator, target_currency) >= rule.threshold_prices[target_currency]
    when 'include_product_models'
      item_model_ids_exist_in_coupon?(items, rule, check_item)
    when 'include_product_categories'
      item_product_category_ids_exist_in_coupon?(items, rule, check_item)
    when 'include_designers'
      item_designers_ids_exist_in_coupon?(items, rule, check_item)
    when 'include_designers_models'
      item_model_ids_exist_in_coupon?(items, rule, check_item) && item_designers_ids_exist_in_coupon?(items, rule, check_item)
    when 'include_works'
      item_work_gids_exist_in_coupon?(items, rule, check_item)
    when 'include_bdevent'
      can_redeem_bdevent?(price_calculator, rule)
    end
  end

  # 計算subtotal
  # coupon指定优惠的item计算subtotal时需要根据base_price_type来计算
  def base_price(price_calculator, target_currency)
    if condition.in?(%w(rules simple)) && !condition_threshold_only
      per_item_total(price_calculator, target_currency)
    else
      price_calculator.order.order_items.inject(0) do |sum, item|
        sum + base_price_for_item(item, target_currency) * item.quantity
      end
    end
  end

  private

  def base_price_for_item(item, target_currency)
    case base_price_type
    when 'original'
      item.original_price_in_currency(target_currency)
    when 'special'
      item.price_in_currency(target_currency)
    end + item.adjustment_value_per_item
  end

  # 新的运费计算涉及到订单价格（包括折扣)
  # 所以启用运费计算后不应该在这里计算运费的折扣
  def discount_for_shipping_fee(price_calculator, target_currency)
    return 0 if SiteSetting.enabled?('ShippingFeeSwitch')
    send(:"#{discount_type}_discount", price_calculator.shipping(target_currency), target_currency)
  end

  def fixed_discount(price, target_currency)
    [price, price(target_currency)].min
  end

  def percentage_discount(price, _target_currency)
    price * percentage
  end

  def pay_discount(price, target_currency)
    price - price(target_currency)
  end

  def once_discount(price_calculator, target_currency, judge_proc)
    calculator_item_map(price_calculator, judge_proc) do |item|
      send(:"#{discount_type}_discount", base_price_for_item(item, target_currency), target_currency)
    end.max
  end

  def order_discount(discount_type, args = {})
    price, target_currency, price_calculator = args.values_at(:price, :target_currency, :price_calculator)
    order_discount = send(discount_type, price, target_currency)
    count_item_discount(order_discount, price_calculator, target_currency)
    order_discount
  end

  def per_item_discount(price_calculator, target_currency)
    items = mark_items(price_calculator, target_currency)
    items.map do |item|
      if item.discount_info.present?
        discount_quantity = item.discount_info.values.sum
        if discount_type == 'percentage'
          discount = percentage_discount(base_price_for_item(item, target_currency), target_currency) * discount_quantity
        else
          discount = calculate_item_discount(item, items, target_currency).round(2)
        end
        item.discount = discount
      else
        0
      end
    end.inject(&:+)
  end

  def calculate_item_discount(item, items, target_currency)
    discount = 0
    item.discount_info.each do |group_index, quantity|
      total_per_group = items.select { |each_item| each_item.discount_info.keys.include?(group_index) }
                             .map { |each_item| base_price_for_item(each_item, target_currency) * quantity }
                             .sum
      discount_per_group = send(:"#{discount_type}_discount", total_per_group, target_currency)
      discount += quantity * base_price_for_item(item, target_currency) / total_per_group.to_f * discount_per_group
    end
    discount
  end

  def per_item_total(price_calculator, target_currency)
    items = mark_items(price_calculator, target_currency)
    items.map do |item|
      if item.discount_info.present?
        discount_quantity = item.discount_info.values.sum
        base_price_for_item(item, target_currency) * discount_quantity + item.adjusted_price_in_currency(target_currency) * (item.quantity - discount_quantity)
      else
        item.adjusted_price_in_currency(target_currency) * item.quantity
      end
    end.inject(&:+)
  end

  def item_work_gids_exist_in_coupon?(items, rule, check_item = false)
    work_gids = rule.work_gids
    work_ids_for_coupon = work_gids.map { |gid| GlobalID::Locator.locate(gid) }.map(&:id)
    items = items.select do |item|
              work_id = item.itemable.try(:original_work_id) || item.itemable.id
              work_id.in?(work_ids_for_coupon)
            end
    items.present? && (check_item || items.to_a.sum(&:quantity) >= rule.quantity)
  end

  def item_model_ids_exist_in_coupon?(items, rule, check_item = false)
    product_model_ids = rule.product_model_ids
    items = items.select { |item| item.itemable.product.id.in?(product_model_ids) }
    items.present? && (check_item || items.to_a.sum(&:quantity) >= rule.quantity)
  end

  def item_product_category_ids_exist_in_coupon?(items, rule, check_item = false)
    product_category_ids = rule.product_category_ids
    return true if product_category_ids.include?(-1)
    items = items.select { |item| item.itemable.category.id.in?(product_category_ids) }
    items.present? && (check_item || items.to_a.sum(&:quantity) >= rule.quantity)
  end

  def item_designers_ids_exist_in_coupon?(items, rule, check_item = false)
    designer_ids = rule.designer_ids
    items = items.select { |item| item.itemable.user_type == 'Designer' && item.itemable.user_id.in?(designer_ids) }
    items.present? && (check_item || items.to_a.sum(&:quantity) >= rule.quantity)
  end

  def quantity_per_group
    coupon_rules.map { |rule| rule.quantity.to_i }.sum
  end

  def can_redeem_bdevent?(price_calculator, rule)
    price_calculator.order.bdevent_id.to_i == rule.bdevent_id.to_i
  end

  # 将对order进行折扣的折扣平分到order_items
  def count_item_discount(order_discount, price_calculator, target_currency)
    items = price_calculator.order.order_items
    discount_items_total = 0
    items.each_with_index do |item, index|
      if index + 1 < items.size
        item_price = base_price_for_item(item, target_currency) * item.quantity
        item_discount = item_price.to_f / price_calculator.subtotal * order_discount
        item.discount = item_discount.round(2)
        discount_items_total += item_discount.round(2)
      else
        item.discount = order_discount - discount_items_total
      end
    end
  end

  # 按价格从高到低排序
  def sort_items(price_calculator, target_currency)
    items = price_calculator.order.order_items
    items.sort { |i1, i2| base_price_for_item(i2, target_currency) <=> base_price_for_item(i1, target_currency) }
  end

  # 给可以进行优惠的order_item加上标志(order_item.discount_info)
  # 根据base_price_type，将order_items从高到低排序进行
  # 最后一组数量和如果小于rules设定的数量，去除标志
  def mark_items(price_calculator, target_currency)
    items = sort_items(price_calculator, target_currency)
    items.each { |item| item.discount_info = {} }
    result = []
    group_amount = (apply_count_limit == -1) ? 99_999 : apply_count_limit
    max_time = 0
    group_amount.times do |group_index|
      max_time = group_index
      coupon_rules.each do |rule|
        next if rule.condition == 'threshold'
        rule_quantity = mark_items_by_rule(items, rule, group_index, price_calculator, target_currency)
        result << rule_quantity
      end
      if result.max == 0
        result = []
      else
        break
      end
    end
    last_discount_items_quantity = items.map {|item| item.discount_info[max_time].to_i}.sum
    if last_discount_items_quantity < quantity_per_group
      items.each {|item| item.discount_info = item.discount_info.delete_if {|key| key == max_time }}
    end
    items
  end

  def mark_items_by_rule(items, rule, group_index, price_calculator, target_currency)
    items_discount_infos = {}
    rule_quantity = rule.quantity
    items.each_with_index do |item, index|
      break if rule_quantity == 0
      can_discount_quantity = item.quantity - item.discount_info.values.sum
      next if can_discount_quantity == 0
      if pass_rule_condition?([item], rule, price_calculator, target_currency, true)
        quantity = [rule_quantity, can_discount_quantity].min
        items_discount_infos[index] = quantity
        rule_quantity -= quantity
      end
    end
    if rule_quantity == 0
      items_discount_infos.each do |index, quantity|
        item = items[index]
        quantity += item.discount_info[group_index].to_i
        item.discount_info[group_index] = quantity
      end
    end
    rule_quantity
  end
end
