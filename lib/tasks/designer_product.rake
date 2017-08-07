namespace :desinger_product do
  task generates_week_sell_report: :environment do
    today = Time.zone.now.to_date
    order_items = OrderItem.past_week.joins(:order)
                  .where(orders: { aasm_state: %w(paid shipping packaged part_refunded part_refunding) })
    order_items = order_items.select { |item| item.itemable.user_type == 'Designer' }
    generate_report(order_items, today)
  end

  task generates_year_sell_report: :environment do
    today = Time.zone.now.to_date
    order_items = OrderItem.after(today.beginning_of_year).joins(:order)
                  .where(orders: { aasm_state: %w(paid shipping packaged part_refunded part_refunding) })
    order_items = order_items.select { |item| item.itemable.user_type == 'Designer' }
    generate_report(order_items, today)
  end

  def order_paid_time(order)
    a =  order.activities.find_by(key: 'paid') ||
         order.activities.where("extra_info->'state_change'->>1 = ?", 'paid').first
    a.try(:created_at)
  end

  def generate_report(items, today)
    File.open("desinger_product_year_sell_report_#{today}.csv", 'w') do |file|
      file.write(
        CSV.generate do |csv|
          header = ['訂單ID',
                    '訂單品項ID',
                    '訂單建立日期',
                    '訂單付款日期',
                    '平台',
                    '設計師商品名稱',
                    '設計師名稱',
                    '產品型號',
                    '原價',
                    '特價優惠金額(原價-特價)',
                    '優惠代碼',
                    '銷售數量',
                    '銷售金額(實售金額)']
          csv << header
          items.each do |item|
            data = [item.order.order_no,
                    item.id,
                    item.order.created_at,
                    order_paid_time(item.order),
                    item.order.platform,
                    item.itemable.name,
                    item.itemable.user.display_name,
                    item.itemable.product.key,
                    item.original_price_in_currency('TWD'),
                    (item.original_price_in_currency('TWD') - item.price_in_currency('TWD')),
                    item.order.embedded_coupon.try(:code),
                    item.quantity,
                    (item.price_in_currency('TWD').to_i - item.discount.to_i)]
            csv << data
          end
        end)
    end
  end
end
