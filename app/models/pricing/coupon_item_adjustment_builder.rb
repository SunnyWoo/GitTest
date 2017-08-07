class Pricing::CouponItemAdjustmentBuilder
  include ActsAsAdjustmentBuilder

  attr_reader :order

  def initialize(order)
    @order = order
  end

  def perform
    groups = group_conformed_items
    # groups_by_item = groups.group_by(&:item)
    discount_info_by_item = merge_discount_info_by_item(groups)
    discount_info_by_item.each do |item, discount_info|
      adjusted_value = if coupon.redeem?
                         # redeem是免费兑换商品
                         item.selling_price * -1
                       else
                         discount_info[:price].value * -1
                       end
      build_adjustment(order, item, coupon, :apply, adjusted_value, discount_info[:quantity])
    end
  end

  def group_conformed_items
    # Spread the items to serial units, the minimum member }
    units = order.to_serial_units

    groups = []
    group_capacity = coupon.apply_count_limit.to_i

    loop do
      break if group_capacity.zero?
      group = Pricing::DiscountGroup.new(coupon.discount_formula, order.currency)

      if grouping_rules.all? { |rule| rule.conformed?(units) && group.push(rule.extract(units)) }
        groups << group
        group_capacity -= 1
      else # dump back the extracted units
        units = (units + group.units).sort
        break
      end
    end

    groups
  end

  def merge_discount_info_by_item(groups)
    groups.flat_map do |group|
      group.discount_info_by_item.to_a
    end.group_by(&:first).each_with_object({}) do |(item, item_and_info), h|
      quantity = item_and_info.sum { |x| x.last[:quantity] }
      price = item_and_info.sum { |x| x.last[:price] }

      h[item] = { quantity: quantity, price: price.with_currency!(order.currency) }
    end
  end

  def coupon
    @coupon ||= order.coupon
  end

  def grouping_rules
    coupon.item_rules
  end
end
