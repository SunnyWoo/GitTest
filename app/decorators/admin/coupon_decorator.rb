class Admin::CouponDecorator < ApplicationDecorator
  delegate_all

  decorates_association :coupon_rules, with: Admin::CouponRuleDecorator

  def rules_info
    case object.condition
    when 'none'
      [I18n.t('js.coupon.new.all_order')]
    when 'shipping_fee'
      [I18n.t('js.coupon.new.shipping_fee')]
    else
      coupon_rules.map(&:info)
    end
  end

  def discount_info
    case object.discount_type
    when 'fixed'
      [I18n.t('js.coupon.new.discount_amount'),
       price_in_currency].join(':')
    when 'percentage'
      [I18n.t('js.coupon.new.discount_percentage'),
       percentage_text].join(':')
    when 'pay'
      [I18n.t('js.coupon.new.pay_amount'),
       price_in_currency].join(':')
    end
  end

  def percentage_text
    [object.percentage > 1 ? object.percentage : object.percentage * 100, '%'].join
  end

  def price_in_currency(currency = Region.default_currency)
    [object.price(currency), currency].join(' ')
  end
end
