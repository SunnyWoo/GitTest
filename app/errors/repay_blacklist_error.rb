class RepayBlacklistError < ApplicationError
  def message
    I18n.t('errors.repay_payment_blacklist', payment: caused_by)
  end

  def status
    :forbidden
  end
end
