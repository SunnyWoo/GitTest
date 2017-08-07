class InvalidError < ApplicationError
  def message
    "#{@caused_by} #{I18n.t('errors.messages.blank')}"
  end
end
