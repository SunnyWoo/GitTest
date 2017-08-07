class SfExpressAdapter
  # 目前只能被用来计算总价
  attr_accessor :package

  delegate :order_items, to: :package

  def initialize(package)
    @package = package
  end

  def shipping_info
    package.orders.first.shipping_info
  end

  def order_no
    package.package_no
  end

  def print_items_count
    package.print_items.size
  end

  def subtotal
    order_items.map do |item|
      item.price_in_currency(item.order.currency)
    end.sum
  end
end
