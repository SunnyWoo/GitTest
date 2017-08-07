class MissingTokenError < ApplicationError
  def message
    I18n.t('errors.missing_token')
  end

  def status
    :unauthorized
  end
end
