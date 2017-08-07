class OrderProcessor
  def initialize(user)
    @user = user
  end

  private

  def build_order(order_params)
    @order = @user.orders.build(order_params)
  end

  def caculate_price
    @order.price
  end
end
