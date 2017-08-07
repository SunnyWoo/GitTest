class InvalidCouponError < ApplicationError
  def message
    I18n.t('errors.invalid_coupon')
  end
end
