class OrderPriceExpirationError < ApplicationError
  def message
    I18n.t('errors.order_price_expiration_error')
  end
end
