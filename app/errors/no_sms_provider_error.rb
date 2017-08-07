class NoSmsProviderError < ApplicationError
  def message
    I18n.t('errors.no_sms_provider', provider: caused_by)
  end

  def status
    :not_found
  end
end
