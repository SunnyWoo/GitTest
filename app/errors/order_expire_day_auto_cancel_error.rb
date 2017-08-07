class OrderExpireDayAutoCancelError < ApplicationError
  def message
    I18n.t('order_expire_day_auto_cancel')
  end

  def status
    :bad_request
  end
end
