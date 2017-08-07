class Print::ShipForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :package_id, :ship_code, :invoice_number, :update_invoice_number,
                :logistics_supplier_id

  def ship!
    if package.split_order?
      fail '发票号码不一致' if invoice_number_not_equal?(package.split_order.invoice_number, invoice_number)
      package.split_order.update(ship_code: ship_code)
    else
      splice_orders.each { |order| order.update(ship_code: ship_code) }
    end
    package.ship_code = ship_code
    package.logistics_supplier_id = logistics_supplier_id
    package.ship!
  rescue => e
    errors.add(:base, e.to_s)
    return false
  end

  private

  def package
    @package ||= Package.find(package_id)
  end

  def splice_order?
    package.orders.size > 1
  end

  def splice_orders
    package.orders if splice_order?
  end

  def invoice_number_not_equal?(order_invoice_number, invoice_number)
    order_invoice_number.to_s.strip != invoice_number.to_s.strip
  end
end
