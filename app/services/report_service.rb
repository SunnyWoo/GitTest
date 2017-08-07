class ReportService
  class << self
    def platform_list
      [['All', ''], ['iOS', 'iOS'], ['Android', 'Android'], ['Web','Web']]
    end

    def country_list
      [
        ['All', ''],
        ['台灣', 'TW'],
        ['日本', 'JA'],
        ['韓國', 'KR'],
        ['中國', 'CN'],
        ['香港', 'HK'],
        ['澳門', 'MO'],
        ['新加坡', 'SG'],
        ['馬來西亞', 'MY']
      ]
    end

    def request_update(order)
      $redis.sadd('reports:update_dates', order.created_at.to_date)
    end

    def execute_update(date)
      Report.where(date: date).destroy_all
      Order.user_was_paid.on_date(date).each do |order|
        Report.create(params_for_report(order))
      end
    end

    def execute_all_updates
      $redis.smembers('reports:update_dates').each do |date|
        execute_update(date)
      end
      $redis.del('reports:update_dates')
    end

    def params_for_report(order)
      {
        order_id: order.id,
        user_id: order.user_id,
        order_item_num: order.order_items.pluck(:quantity).inject(&:+),
        subtotal: order.price_calculator.subtotal('TWD'),
        price: order.price_calculator.price('TWD'),
        coupon_price: order.price_calculator.discount('TWD'),
        shipping_fee: order.price_calculator.shipping('TWD'),
        refund: order.price_calculator.refund('TWD'),
        total: order.price_calculator.price('TWD') - order.price_calculator.refund('TWD'),
        country_code: order.shipping_info_country_code,
        platform: order.platform,
        date: order.created_at.to_date,
        shipping_fee_discount: order.price_calculator.actual_shipping_fee_discount('TWD')
      }
    end

    def to_csv(reports)
      column_titles = ['Date', 'Platform', 'Country','Order Qty.',
       'Item Qty.', 'Member Qty.', 'Visitor Qty.', 'Subtotal', 'Discount',
       'Shipping Fee', 'Price', 'Refund',
       'Total', 'Amount per Order', 'Amount per User']

      columns = [ 'date', 'platform', 'country_code','total_orders',
       'items_amount', 'users_amount', 'vistor_total', 'subtotal', 'discount',
       'shipping_fee', 'price', 'total_refund',
       'total', 'avg_order_price', 'avg_per_user_price']
      CSV.generate do |csv|
        csv << column_titles
        reports.each do |report|
          csv << report.attributes.values_at(*columns)
        end
      end
    end
  end
end
