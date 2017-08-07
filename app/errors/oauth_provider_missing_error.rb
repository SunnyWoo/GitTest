class OauthProviderMissingError < ApplicationError
  def message
    I18n.t('errors.oauth_provider_missing', provider: caused_by)
  end

  def status
    :not_found
  end
end
