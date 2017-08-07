class RecordInvalidError < ApplicationError
  def message
    I18n.t('errors.record_invalid')
  end

  def status
    :unprocessable_entity
  end

  def as_json(*)
    super.merge(detail: caused_by.record.errors.full_messages.join(', '))
  end
end
