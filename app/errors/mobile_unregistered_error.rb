class MobileUnregisteredError < ApplicationError
  def message
    I18n.t('errors.mobile_unregistered')
  end
end
