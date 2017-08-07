class MobileRegisteredError < ApplicationError
  def message
    I18n.t('errors.mobile_registered')
  end
end
