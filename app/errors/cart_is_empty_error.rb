class CartIsEmptyError < ApplicationError
  def message
    I18n.t('errors.cart_is_empty')
  end
end
