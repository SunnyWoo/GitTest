class PaymentStateTransitionError < ApplicationError
  def message
    I18n.t('errors.payment_state_transition', state: caused_by)
  end

  def status
    :forbidden
  end
end
