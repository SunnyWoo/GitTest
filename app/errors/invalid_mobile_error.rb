class InvalidMobileError < ApplicationError
  def message
    I18n.t('errors.invalid_mobile_error')
  end
end
