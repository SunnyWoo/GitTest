class GuanyiTradeForm
  include ActiveModel::Model
  include ActiveModel::Validations

  EXPRESS_CODES = %w(SF YTO DBWL).freeze

  attr_accessor :deal_datetime, :platform_code,
                :shop_code, :warehouse_code, :vip_code, :express_code,
                :receiver_name, :receiver_address, :receiver_zip,
                :receiver_mobile, :details, :payments, :service

  validates :receiver_mobile, presence: true
  validates :express_code, inclusion: {
    in: EXPRESS_CODES, message: I18n.t('errors.invalid_express_code')
  }

  def initialize(order)
    @deal_datetime = order.created_at.strftime('%Y-%m-%d %H:%M:%S')
    @platform_code = order.order_no

    @shop_code = 'commandp-sh'
    @warehouse_code = 'factory-sh'
    @vip_code = 'customer'
    @express_code = 'SF'

    shipping_info = order.shipping_info
    @receiver_name = shipping_info.name
    @receiver_address = shipping_info.full_address
    @receiver_zip = shipping_info.zip_code
    @receiver_mobile = shipping_info.phone.gsub(/[+]/, '')
    @details = trade_details(order)
    @payments = [
      {
        payment: order.price.to_s,
        pay_type_code: map_order_payment(order.payment)
      }
    ]
    @service = GuanyiService.new
  end

  def attributes
    {
      deal_datetime: @deal_datetime,
      platform_code: @platform_code,

      shop_code: @shop_code,
      warehouse_code: @warehouse_code,
      vip_code: @vip_code,
      express_code: @express_code,

      receiver_name: @receiver_name,
      receiver_address: @receiver_address,
      receiver_zip: @receiver_zip,
      receiver_mobile: @receiver_mobile,
      details: @details,
      payments: @payments
    }
  end

  def post!
    @service.request('gy.erp.trade.add', attributes) if valid?
  end

  private

  def map_order_payment(order_payment)
    if order_payment =~ /pingpp_alipay/
      'zhifubao'
    elsif order_payment =~ /pingpp_upacp/
      'yinlian'
    elsif order_payment =~ /pingpp_wx/
      'wenxin'
    elsif order_payment =~ /cash_on_delivery/
      'cod'
    else
      'balance'
    end
  end

  def trade_details(order)
    order.order_items.map do |item|
      {
        qty: item.quantity.to_s,
        price: item.prices['CNY'].to_s,
        item_code: item.itemable.product_code
      }
    end
  end
end
