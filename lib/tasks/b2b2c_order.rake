namespace :b2b2c_order do
  task daily_report: :environment do
    orders = Order.shop.yesterday.order(:channel)
    file_path = generate_file(orders, 'daily')
    ReportMailer.b2b2c_order_report(file_path: file_path).deliver
  end

  task weekly_report: :environment do
    orders = Order.shop.past_week.order(:channel)
    file_path = generate_file(orders, 'weekly')
    ReportMailer.b2b2c_order_report(file_path: file_path).deliver
  end

  def generate_file(orders, type)
    today = DateTime.current
    file_name = "b2b2c_orders_for_#{type}_report_#{today}.csv"
    File.open(file_name, 'w+') do |file|
      file.write(
        CSV.generate do |csv|
          headers = %w(商店名稱
                       訂單編號
                       建立日期
                       狀態
                       付款日期
                       付款方式
                       使用貨幣
                       優惠代碼
                       訂單金額
                       優惠折扣
                       運費
                       運費折扣
                       實付金額
                       設計師或客製化
                       設計師名稱
                       產品分類
                       產品型號
                       產品價格
                       銷售數量)
          csv << headers
          orders.each do |order|
            order_info = [
              order.shop_name,
              order.order_no,
              order.created_at,
              order.aasm_state,
              order.paid_at,
              order.payment,
              order.currency,
              order.embedded_coupon.try(:code),
              order.subtotal,
              order.discount,
              order.shipping_fee,
              order.shipping_fee_discount,
              order.price
            ]
            csv << order_info
            order.order_items.each do |item|
              item_info = Array.new(order_info.size)
              item_info.concat [
                item.itemable_name,
                item.itemable.user.name,
                item.itemable.category.name,
                item.itemable.product.name,
                item.price_in_currency(item.order.currency),
                item.quantity
              ]
              csv << item_info
            end
          end
        end
      )
    end
    File.join(Dir.pwd, file_name)
  end
end
