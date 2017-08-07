# 這個 service 是要來 import 來自 taobao 的訂單
class TaobaoImportService
  def initialize
    @user = User.find_by!(email: 'commandp_sh@commandp.com')
    @coupon = Coupon.find_by code: 'TBQM2016'
  end

  def generate_orders(orders_data)
    orders_data.each do |taobao_order_id, order_info|
      build_order_row(order_info, taobao_order_id)
    end
  end

  def build_order_row(order_info, taobao_order_id)
    order = Order.new(user: @user, currency: 'CNY', payment: 'paypal')
    order.taobao_order_id = taobao_order_id
    order_info[:order_items].each do |item|
      work = GlobalID::Locator.locate(item[:work_gid])
      order.order_items.build(itemable: work, quantity: item[:quantity])
    end
    order.build_shipping_info(order_info[:billing_info])
    order.build_billing_info(order_info[:billing_info])
    order.coupon = @coupon if @coupon
    order.save
    order.pay!
    order.approve!
    order.reload
    #order.order_items.update_all(aasm_state: :sublimated)
    #order.print_items.update_all(aasm_state: :sublimated)
  end

  def parse_csv_to_order_params(filename)
    orders = {}
    CSV.foreach(filename) do |row|
      # 订单编号  标题  价格  购买数量  外部系统编号  商品属性  套餐信息  备注  订单状态  商家编码  收貨人姓名 手机号  地址
      next if row[0] == '订单编号'
      orders[row[0]] ||= { order_items: [] }
      std_work = StandardizedWork.find(row[4])
      fail "StandardizedWork can't find #{row[4]}" unless std_work
      orders[row[0]][:order_items] << {
        quantity: row[3],
        work_gid: std_work.to_gid.uri.to_s
      }
      orders[row[0]][:billing_info] = {
        name: row[10],
        phone: row[11],
        state: row[12],
        city: row[13],
        address: "#{row[14]} #{row[15]}",
        country: 'China',
        country_code: 'CN',
        email: 'commandp_sh@commandp.com'
      }
    end
    orders
  end
end
