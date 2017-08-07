class WorkNotFoundError < ApplicationError
  def message
    I18n.t('errors.work_not_found_error')
  end
end
