class OrderItemsEmptyError < ApplicationError
  def message
    I18n.t('errors.order_items_empty')
  end

  def status
    :bad_request
  end
end
