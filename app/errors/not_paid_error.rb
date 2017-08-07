class NotPaidError < ApplicationError
  def message
    I18n.t('errors.stripe.not_paid')
  end

  def status
    :bad_request
  end
end
