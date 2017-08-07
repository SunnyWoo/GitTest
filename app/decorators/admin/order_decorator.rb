class Admin::OrderDecorator < ApplicationDecorator
  decorates Order
  delegate_all
  delegate :message, to: :object

  decorates_association :shipping_info, with: BillingProfileDecorator
  decorates_association :billing_info, with: BillingProfileDecorator

  def self.model_name
    Order.model_name
  end

  def tags
    [].tap do |t|
      t << I18n.t('order.payment.nuandao_b2b') if nuandao_b2b?
    end
  end

  def flag_names
    object.flags.map { |flag| I18n.t("orders.show.flags.#{flag}") }
  end
end
