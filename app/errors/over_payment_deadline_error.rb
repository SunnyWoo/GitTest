class OverPaymentDeadlineError < ApplicationError
  def message
    I18n.t('errors.over_payment_deadline')
  end
end
