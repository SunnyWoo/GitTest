class Api::V3::OrderDecorator < ApplicationDecorator
  decorates Order
  delegate_all
  delegate :message, to: :object

  decorates_association :shipping_info, with: BillingProfileDecorator
  decorates_association :billing_info, with: BillingProfileDecorator

  def self.model_name
    Order.model_name
  end

  def order_items
    @order_items ||= source.order_items.map do |order_item|
      Api::V3::OrderItemDecorator.spread_by_coupon_discount(order_item)
    end.flatten
  end

  def payment_info
    if source.payment == 'neweb/atm'
      source.payment_info.merge(
        'bank_id' => source.payment_object.bank_id,
        'bank_name' => source.payment_object.bank_name
      )
    else
      source.payment_info
    end
  end

  def deferred_adjusted?
    deferred_adjustments.any?
  end

  def deferred_adjustment_info
    deferred_adjustments.map do |adj|
      { id: adj.id, reason: adj.reason, created_at: adj.created_at.to_s }
    end
  end

  def pricing_identifier
    @pricing_identifier ||= Digest::MD5.hexdigest([id, actual_pricing_target, price, actual_adjustments.size].join('-'))
  end

  def pricing_expired_at
    return nil if pending?
    recent_ending_promotion_expiration
  end

  def deferred_adjustments
    @deferred_adjustments ||= actual_adjustments.select(&:deferred?)
  end

  def promotions
    @promotions ||= Order::PromotionsProxy.build(source)
  end

  def pricing
    ans = {
      subtotal: source.subtotal,
      discount: discount,
      shipping_fee: source.shipping_fee,
      price: source.price,
      expired_at: pricing_expired_at,
      identifier: pricing_identifier
    }

    ans[:adjustments] = deferred_adjustment_info if deferred_adjusted?
    ans[:valid] = source.shipping_fee.present?
    ans[:error] = I18n.t("address_unavailable", scope: 'errors.pricing.shipping_fee') if source.shipping_fee.nil?
    ans
  end

  def discount
    source.discount + source.shipping_fee_discount
  end

  private

  def actual_pricing_target
    base_price_type
  end

  def recent_ending_promotion_expiration
    promotions.recent_ending.first.try(:ends_at)
  end

  def actual_adjustments
    @actual_adjustments ||= source.adjustments.order('id desc')
  end
end
