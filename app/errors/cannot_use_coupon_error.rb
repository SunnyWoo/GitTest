class CannotUseCouponError < ApplicationError
  def message
    I18n.t('errors.cannot_use_coupon')
  end

  def status
    :unprocessable_entity
  end
end
