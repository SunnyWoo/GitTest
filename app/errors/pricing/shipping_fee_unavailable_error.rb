class Pricing::ShippingFeeUnavailableError < ApplicationError
  def message
    I18n.t("unavailable", scope: 'errors.pricing.shipping_fee')
  end
end
