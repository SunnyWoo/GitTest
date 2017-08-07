class Guanyi::ExportOrders
  LIST_ROW_NAMES = %w(订单编号 买家会员名称 运费 支付金额 订单状态 买家留言 收货人 收货地址 联系电话 联系手机 订单创建时间 订单付款时间
                      物流单号 物流公司 卖家备注 店铺名称 发票抬头 是否手机订单 是否货到付款 支付方式 支付交易号 真实姓名 身份证号).freeze
  DETAIL_ROW_NAMES = %w(订单编号 标题 价格 购买数量 商品代码 规格名称 备注).freeze
  COMPLETED_STATUS = '外部系统已完成'.freeze
  INITIALIZE_STATUS = '买家已付款，等待卖家发货'.freeze

  attr_reader :start_time, :end_time, :export_day, :list_filename, :details_filename

  def initialize(ship_start_time, ship_end_time)
    @start_time = ship_start_time
    @end_time = ship_end_time

    @export_day = ship_end_time.strftime('%Y-%m-%d')
    @list_filename = "list-#{export_day}.xlsx"
    @details_filename = "details-#{export_day}.xlsx"
  end

  def generate_zip
    list
    details
    taobao_orders
    ZipFileGenerator.new(excel_dir, zip_output).write
    yield zip_output
    clean!
  end

  def orders
    @orders ||= Order.shipping.where(shipped_at: start_time..end_time).where.not(payment: 'taobao_b2c')
  end

  def list
    Axlsx::Package.new do |excel|
      excel.workbook.add_worksheet(name: 'Sheet1') do |sheet|
        sheet.add_row LIST_ROW_NAMES
        export_order_list(sheet)
      end
      excel.serialize("#{excel_dir}#{list_filename}")
    end
  end

  def details
    Axlsx::Package.new do |excel|
      excel.workbook.add_worksheet(name: 'Sheet1') do |sheet|
        sheet.add_row DETAIL_ROW_NAMES
        export_order_details(sheet)
      end
      excel.serialize("#{excel_dir}#{details_filename}")
    end
  end

  def taobao_orders
    taobao_orders = Order.shipping.where(shipped_at: start_time..end_time, payment: 'taobao_b2c')
    CSV.open("#{excel_dir}taobao_orders.csv", 'wb') do |csv|
      csv << %w(订单号 管易订单号 管易平台单号 物流单号)
      taobao_orders.find_each do |taobao_order|
        csv << [taobao_order.order_no,
                taobao_order.guanyi_order_guanyi_trade_code,
                taobao_order.guanyi_order_guanyi_platform_code,
                taobao_order.packages.last.try(:ship_code)]
      end
    end
  end

  private

  def export_order_list(sheet)
    orders.includes(:shipping_info, :billing_info).find_each.each do |order|
      sheet.add_row [
        order.order_no,                                  # 订单编号
        order.billing_info_name,                         # 买家会员名称
        order.shipping_fee,                              # 运费
        order.price,                                     # 支付金额
        order_state(order),                              # 订单状态
        '',                                              # 卖家留言
        order.shipping_info_name,                        # 收货人
        order.shipping_info_address,                     # 收货地址
        '',                                              # 联系电话
        order.shipping_info_phone,                       # 联系手机
        order.created_at.strftime('%Y-%m-%d %H:%M:%S'),  # 订单创建时间
        order.paid_at.strftime('%Y-%m-%d %H:%M:%S'),     # 订单付款时间
        order.ship_code,                                 # 物流单号
        '圆通快递', # 物流公司 TODO: 暂时全部设为圆通快递
        '', # 卖家备注
        order.delivered? ? '优印台湾' : '优印上海', # 店铺名称
        '', # 发票抬头
        '否',                                            # 是否手机订单
        '否',                                            # 是否货到付款
        map_order_payment(order.payment),                # 支付方式
        '',                                              # 支付交易号
        '',                                              # 真实姓名
        '',                                              # 身份证号
      ]
    end
  end

  def order_state(order)
    order.invoice_required? ? INITIALIZE_STATUS : COMPLETED_STATUS
  end

  def export_order_details(sheet)
    orders.includes(order_items: :itemable).find_each.each do |order|
      order_items = reduce_order_item_by_product_code(order)
      order_items.values.each do |order_item|
        sheet.add_row [
          order_item[:order_no], # 订单编号
          work_name(order_item[:itemable_name]), # 标题
          order_item[:price],                      # 价格
          order_item[:quantity],                   # 购买数量
          order_item[:product_code],               # 商品代码
          order_item[:sku],                        # 规格名称
          order_item[:note]                        # 备注
        ]
      end
    end
  end

  # 备注: 因为product_code和order_no不能重复, 所以将相同product_code的数量叠加
  def reduce_order_item_by_product_code(order)
    order.order_items.each_with_object({}) do |order_item, new_items|
      product_code_key = order_item.itemable.product_code.to_sym
      if new_items.keys.include?(product_code_key)
        new_items[product_code_key][:quantity] = new_items[product_code_key][:quantity].to_i + order_item.quantity.to_i
      else
        new_items[product_code_key] = {
          order_no: order_item.order.order_no,
          itemable_name: order_item.itemable_name,
          price: order_item.prices['CNY'].to_s,
          quantity:  order_item.quantity,
          product_code: order_item.itemable.product_code,
          sku: '',
          note: ''
        }
      end
    end
  end

  def map_order_payment(order_payment)
    case order_payment
    when /pingpp_alipay/
      'zhifubao'
    when /pingpp_upacp/
      'yinlian'
    when /pingpp_wx/
      'wenxin'
    when /cash_on_delivery/
      'cod'
    else
      'balance'
    end
  end

  def folder
    folder = "#{Rails.root}/tmp/export_order/"
    FileUtils.mkdir_p(folder) unless File.directory?(folder)
    folder
  end

  def excel_dir
    excel_dir = "#{folder}#{export_day}/"
    FileUtils.mkdir_p(excel_dir) unless File.directory?(excel_dir)
    excel_dir
  end

  def zip_output
    "#{folder}#{export_day}.zip"
  end

  def clean!
    FileUtils.rm_rf(folder) if File.directory?(folder)
  end

  def work_name(name)
    name.strip.blank? ? '未命名' : name.strip
  end
end
