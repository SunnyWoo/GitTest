class RecordNotFoundError < ApplicationError
  def initialize(error_message = nil)
    @error_message = error_message
  end

  def message
    @error_message || I18n.t('errors.record_not_found')
  end

  def status
    :not_found
  end
end
