class AlreadyVerifiedError < ApplicationError
  def message
    I18n.t('errors.already_verified')
  end
end
