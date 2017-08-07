class PaymentStateError < ApplicationError
  def message
    I18n.t('errors.payment_state_error')
  end

  def status
    :forbidden
  end
end
