class CurrentUserRequiredError < ApplicationError
  def message
    I18n.t('errors.current_user_required')
  end

  def status
    :forbidden
  end
end
