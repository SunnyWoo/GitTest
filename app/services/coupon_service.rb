class CouponService
  # coupon.title.csv
  def self.export_children(coupon)
    CSV.generate do |csv|
      coupon.children.find_in_batches(batch_size: 3000) do |child_coupons|
        child_coupons.each do |child_coupon|
          is_used_text = child_coupon.is_used? ? I18n.t('js.coupon.index.used') : I18n.t('js.coupon.index.unused')
          csv << [sprintf('="%s"', child_coupon.code), is_used_text]
        end
      end
    end
  end

  def self.export_used_orders(coupon)
    search = Order.ransack(coupon_title_or_coupon_code_eq: coupon.title)
    orders = search.result
    columns = %w(訂單編號 訂單成立時間 幣值 訂單總金額 物流方式 目的地（國家） 製作平台)
    CSV.generate do |csv|
      csv << columns
      orders.each do |order|
        csv << [order.order_no, order.created_at.strftime('%Y/%m/%d'), order.currency, order.price,
                order.shipping_info_shipping_way, order.shipping_info_country, order.platform]
      end
    end
  end

  def self.export_available_coupons
    coupons = Coupon.root.where('expired_at > :time', time: Time.zone.now)
    coupons = Admin::CouponDecorator.decorate_collection(coupons)
    columns = %w(优惠码名称 优惠码开始日期 优惠码结束日期 优惠条件一 优惠条件二 优惠方式)
    CSV.generate do |csv|
      csv << columns
      coupons.each do |coupon|
        coupon = Admin::CouponDecorator.new(coupon)
        csv << [coupon.title,
                coupon.begin_at,
                coupon.expired_at,
                coupon.rules_info[0],
                coupon.rules_info[1],
                coupon.discount_info
                ]
      end
    end
  end
end
