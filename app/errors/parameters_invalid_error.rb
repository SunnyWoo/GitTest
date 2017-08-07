class ParametersInvalidError < ApplicationError
  def message
    I18n.t('errors.parameter_invalid', caused_by: caused_by)
  end

  def status
    :bad_request
  end
end
