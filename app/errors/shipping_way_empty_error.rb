class ShippingWayEmptyError < ApplicationError
  def message
    I18n.t('errors.shipping_way_empty')
  end

  def status
    :bad_request
  end
end
