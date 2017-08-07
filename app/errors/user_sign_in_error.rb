class UserSignInError < ApplicationError
  def message
    I18n.t('errors.invalid_login_info')
  end

  def status
    :unauthorized
  end

  def as_json(*)
    super.merge(detail: message)
  end
end
