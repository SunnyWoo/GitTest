class CouponMessageFormatError < ApplicationError
  def message
    I18n.t('errors.coupon_message_format')
  end
end
