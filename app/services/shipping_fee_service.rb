class ShippingFeeService
  attr_accessor :order, :shipping_info, :logistics_supplier_name, :shipping_way

  def initialize(order, logistics_supplier_name = nil, shipping_way = nil)
    @order = order
    @shipping_info = order.shipping_info
    @logistics_supplier_name = logistics_supplier_name
    @shipping_way = shipping_way.present? ? shipping_way : @shipping_info.shipping_way
  end

  def price
    # https://app.asana.com/0/9672537926113/153207363349606
    # 因為 nuandao_b2b無法回傳 province_id 先固定運費 0元
    return 0 if order.payment == 'nuandao_b2b'
    return global_to_tw_price(order.currency) if !china? && country_code == 'TW'
    return nil if country_code.blank?
    return nil if china? && province_in_address.nil?
    return nil if normal_shipping_fee.nil?

    over_price = 0
    if overweight > 0 && overweight_shipping_fee
      over_price = (overweight / overweight_shipping_fee.weight).ceil * overweight_shipping_fee.price
    end
    shipping_fee = normal_shipping_fee.price + over_price
    return shipping_fee if china?
    # global 有多个currency，将运费转换成订单的currency
    CurrencyExchangeService.new(shipping_fee, default_currency, order.currency).execute
  end

  private

  def global_to_tw_price(currency)
    fee = Fee.find_by(name: 'global_to_tw_price')
    fee ? fee.price_in_currency(currency) : ShippingFee::GLOBAL_TO_TW_PRICE
  end

  def country_code
    shipping_info.country_code
  end

  def province
    if has_special_city?
      Province.find_by_name(Province::SPECIAL_NAME)
    else
      province_in_address
    end
  end

  def address
    if shipping_info.address_data.present?
      shipping_info.address_data
    else
      shipping_info.convert_legacy_address
    end
  end

  def province_in_address
    shipping_info.province || Province.find_by_id(address.province_id)
  end

  def logistics_supplier
    name = if china?
             logistics_supplier_name || default_logistics_supplier_name
           elsif country_code.in? %w(CN TW HK MO)
             '順豐'
           else
             'EMS'
           end
    LogisticsSupplier.find_by_name(name)
  end

  def order_price
    price = order.subtotal - order.discount
    return price if china?
    # global寄送到TW的满499会免运费，所以需要转换TWD判断
    CurrencyExchangeService.new(price, order.currency, 'TWD').execute
  end

  def order_weight
    order.weight
  end

  def normal_shipping_fee
    normal_weight = overweight > 0 ? first_chargeable_weight : order_weight
    shipping_fees = ShippingFee::Normal.where(country: country_code, logistics_supplier: logistics_supplier)
                                       .where('weight >= ?', normal_weight)
                                       .order(:weight)
    shipping_fees = shipping_fees.where(province: province) if china?
    shipping_fees.first
  end

  def overweight_shipping_fee
    shipping_fees = ShippingFee::Overweight.where(country: country_code,
                                                  logistics_supplier: logistics_supplier,
                                                  weight: increment_weight)
    shipping_fees = shipping_fees.where(province: province) if china?
    shipping_fees.first
  end

  def overweight
    order_weight - first_chargeable_weight
  end

  # 首重
  # china： 1kg以内统一按1kg计算
  # global：10kg以内都有固定的价格
  def first_chargeable_weight
    china? ? 1000 : 10_000
  end

  def china?
    Region.china?
  end

  # 超过首重的都是按 1kg为单位进行计算价格
  def increment_weight
    1000
  end

  # 顺丰特惠等前端有加价选项后才有
  # 现在暂定 快速运送(express) 使用顺丰特惠
  def default_logistics_supplier_name
    case shipping_way
    when 'standard'
      '韵达'
    when 'express'
      '顺丰特惠'
    else
      '韵达'
    end
  end

  # 江苏省（宿迁、连云港、徐州）使用顺丰计算运费和江苏省不同
  def has_special_city?
    return false if province_in_address.try(:name) != '江苏省'
    addr = address.full_address
    %w(宿迁市 连云港市 徐州市).any? { |city| city.in?(addr) }
  end

  def default_currency
    china? ? 'CNY' : 'TWD'
  end
end
