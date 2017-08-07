class TooManyRequestError < ApplicationError
  def message
    I18n.t('errors.too_many_request')
  end
end
