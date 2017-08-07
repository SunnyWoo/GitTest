class InvalidUrlError < ApplicationError
  def message
    I18n.t('errors.invalid_url')
  end
end
