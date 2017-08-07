class ServiceTypeError < ApplicationError
  def message
    I18n.t('errors.service_type')
  end

  def status
    :not_acceptable
  end
end
