module FreeChecking
  extend ActiveSupport::Concern

  def free_checking(order, cart)
    free = (order.price == 0)
    if free
      order.pay!
      cart.clean(order)
      redirect_to order_result_path(order.order_no)
    end
    free
  end
end
