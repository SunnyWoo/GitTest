class PaymentMethodNotAllowedError < ApplicationError
  def message
    I18n.t('errors.payment_type_error')
  end

  def status
    :forbidden
  end
end
