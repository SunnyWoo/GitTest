class WorkNotFinishError < ApplicationError
  def message
    I18n.t('errors.work_not_finish_error')
  end
end
