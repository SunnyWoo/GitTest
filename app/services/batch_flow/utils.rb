module BatchFlow::Utils
  def generate_item_code(order, order_item_serial, product, quantity)
    serial_code = order_item_serial.to_s.rjust(2, '0')
    order_code = order.id.to_s(16)[0, 5].rjust(5, '0').upcase
    "#{order_code}_#{serial_code}_#{product.external_code}_#{quantity}"
  end

  def source_location_code
    Region.china? ? "CN" : "TW"
  end
end
