class PaymentPriceConflictError < ApplicationError
  def message
    I18n.t('errors.payment_price_conflict')
  end

  def status
    :conflict
  end

  def as_json(*)
    super.merge(detail: caused_by)
  end
end
