class AuthenticationFailedError < ApplicationError
  def message
    I18n.t('errors.authentication_failed')
  end

  def status
    :unauthorized
  end
end
