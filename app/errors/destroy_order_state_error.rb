class DestroyOrderStateError < ApplicationError
  def message
    I18n.t('errors.destroy_order_state_error')
  end

  def status
    :forbidden
  end
end
