class SfExpress::Order < SfExpressService
  include Print::PdfHelper

  # 下订单（含筛选）接口
  # example: SfExpress::Order.new(Order.last).execute
  # 此处只列取必填参数详细参数见 https://app.asana.com/0/42686877023074/52400225332580  附件
  # http://www.sf-express.com/cn/sc/platform/sd/detail/order.html
  # _SYSTEM表示如果不提如供，将从系统配置获取
  #
  # response
  #   success:
  #       {
  #         "destcode" => "021",
  #         "mailno" => "444436912525",
  #         "origincode" => "021",
  #         "orderid" => "1510231100036CN"
  #       }
  #   error:
  #      {
  #        "error" => "重复下单TW"
  #      }

  # 订单信息
  mapping :order, orderid: '',               # 客户订单号
                  mailno: '',                # 顺丰运单号,对于路由推送注册，此字段为必填
                  express_type: 1,           # 快件产品类别 1 标准快递  2 顺丰特惠 3 电商特惠
                  j_province: '_SYSTEM',     # 寄件方所在省份
                  j_city: '_SYSTEM',         # 寄件方所属城市名称
                  j_company: '_SYSTEM',      # 寄件方公司名称
                  j_contact: '_SYSTEM',      # 寄件方联系人
                  j_tel: '_SYSTEM',          # 寄件方联系电话
                  j_address: '_SYSTEM',      # 寄件方详细地址
                  j_post_code: nil,          # 寄方邮编，跨境件必填(中国大陆，港澳台互寄除外)
                  j_shippercode: nil,        # 寄件方国家/城市代码,如果是跨境 件,则此字段为必填
                  d_company: '',             # 到件方公司名称
                  d_contact: '',             # 到件方联系人
                  d_tel: '',                 # 到件方联系电话
                  d_address: '',             # 到件方详细地址
                  d_post_code: nil,          # 到方邮编，跨境件必填(中国大陆，港澳台互寄除外)
                  d_province: '',            # 到件方所在省份
                  d_city: '',                # 到件方所属城市
                  pay_method: 1,             # 付款方式： 1: 寄方付 2: 收方付 3: 第三方付，默认为 1
                  parcel_quantity: 1,        # 包裹数
                  declared_value: nil,       # 客户订单货物总声明价值 跨境件报关需要填写
                  declared_value_currency: 'NTD',   # 货物声明价值币别 跨境件报关需要填写
                  custid: '_SYSTEM',         # 顺丰月结卡号

                  is_docall: '_SYSTEM',      # 是否下call，1-下 其他否
                  is_gen_bill_no: '_SYSTEM'  # 是否申请运单号，1-申请运单号 其他否
  # 货物信息
  mapping :cargo, name: '',
                  currency: 'NTD',           # 货物单价的币别 跨境件报关需要填写
                  count: nil,                # 货物数量 跨境件报关需要填写
                  unit: '个',                # 货物单位，如：个、台、本，跨境件报关需要填写。
                  weight: 0.363,             # 订单货物单位重量,包含子母件,单位千克,精确到小数点后3 位跨境件报关需要填写。
                  source_area: '中国'        # 原产地国别，跨境件报关需要填写。

  def initialize(order)
    self.order = order
  end

  def generate
    shipping_info = order.shipping_info
    mapping_order = mappings[:order]
    mapping_order[:orderid] = order.order_no
    mapping_order[:d_contact] = shipping_info.name
    mapping_order[:d_tel] = shipping_info.phone
    mapping_order[:d_address] = shipping_info.full_address
    mapping_order[:d_city] = shipping_info.city
    mapping_order[:d_post_code] = shipping_info.zip_code
    mapping_order[:d_deliverycode] = d_deliverycode(shipping_info.country)
    mapping_order[:j_tel] = Settings.sf_express.j_tel
    mapping_order[:j_address] = J_ADDRESS
    mapping_order[:j_company] = J_COMPANY
    mapping_order[:j_contact] = J_COMPANY
    mapping_order[:j_post_code] = J_POST_CODE
    mapping_order[:j_shippercode] = J_SHIPPERCODE
    mapping_order[:declared_value] = order.subtotal
    mapping_order[:custid] = Settings.sf_express.custid

    mapping_cargo = mappings[:cargo]
    mapping_cargo[:count] = order.print_items_count
    mapping_cargo[:name] = render_order_item_info(order)
  end

  def request_xml
    generate
    Gyoku.xml(
      'Request' => {
        'Head' => Settings.sf_express.code,
        'Body' => {
          'Order' => {
            'Cargo' => '',
            :attributes! => { 'Cargo' => check_params(mappings[:cargo]) }
          },
          :attributes! => { 'Order' => check_params(mappings[:order]) }
        }
      },
      :attributes! => { 'Request' => { 'service' => 'OrderService', 'lang' => 'zh-TW' } }
    )
  end

  def result(response_json)
    head = response_json['Response']['Head']
    if head == 'OK'
      response_json['Response']['Body']['OrderResponse']
    elsif head == 'ERR'
      error_result(response_json['Response']['ERROR'])
    else
      fail SfExpressError, response_json
    end
  end

  def d_deliverycode(country)
    case country
    when 'Taiwan'
      886
    when 'Macao'
      853
    when 'Hong Kong'
      852
    else
      nil
    end
  end
end
