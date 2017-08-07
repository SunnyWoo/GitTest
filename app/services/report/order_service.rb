class Report::OrderService
  def initialize(orders, locale = :'zh-CN')
    @orders = orders.includes(:activities, :billing_info, :shipping_info, order_items: [itemable: [product: :translations]])
    @locale = locale
  end

  def rows
    @rows ||= @orders.order('id ASC').map { |o| Serializer.new(o).to_hash }
  end

  def csv_row(row, item, style: :default, need_full_info: false)
    slice = row.slice(:id, :order_no, :payment_method, :created_at, :paid_at, :approved_at,
                      :state, :coupon_title, :currency, :subtotal,
                      :discount, :shipping_fee, :shipping_fee_discount, :price).values
    need_full_info = true if style == :product
    if style == :finance
      slice2 = row.slice(:id, :order_no, :payment_method, :created_at, :paid_at, :approved_at, :state, :coupon_title).values
      ret = need_full_info ? slice : slice2 + [nil] * (slice.count - slice2.count)
      ret += item.values
      ret << row[:user_id]
      ret += row[:shipping_info].values
      ret << row[:platform] if need_full_info
    else
      ret = need_full_info ? slice : [nil] * slice.count
      ret += item.values
      if need_full_info
        ret << row[:user_id]
        ret += row[:shipping_info].values
        ret << row[:platform]
      end
    end

    ret
  end

  def to_csv(style: :default)
    bom_head = %w(EF BB BF).map { |a| a.hex.chr }.join
    CSV.generate(csv = bom_head) do |csv|
      csv << column_titles
      rows.each do |row|
        row[:items].each_with_index do |item, i|
          csv << csv_row(row, item, style: style, need_full_info: i == 0)
        end
      end
    end
  end

  def column_titles
    if @locale == :'zh-CN'
      %w(ID 订单编号 付款方式 建立日期 付款日期 审核通过日期 状态 优惠券类型 币值 订单金额
         优惠券抵用金额 运费 运费减免 实付金额 产品分类 产品分类名称 购买型号 购买型号名称 抛单物品 设计师或客制化 设计师 设计师产品名称 产品原价 产品单价 产品实单价 数量 订单原价 抵用 运费 实付 使用者ID 收货人 email 电话 省/州 城市 县市
         收货信息 发货日期 物流公司 物流单号 制作平台)
    else
      %w(ID 訂單編號 付款方式 建立日期 付款日期 審核通過日期 狀態 優惠券類型 幣值 訂單金額
         優惠券抵用金額 運費 運費減免 實付金額 產品分類 產品分類名稱 購買型號 購買型號名稱 拋單物品 設計師或客製化 設計師 設計師產品名稱 產品原價 產品單價 產品實單價 數量 訂單原價 抵用 運費 實付 使用者ID 收貨人 Email 電話 省/州 城市 縣市 收貨信息
         發貨日期 物流公司 物流單號 制作平台)
    end
  end

  class Serializer
    attr_reader :order

    def initialize(order, locale = :'zh-CN')
      @order = order
      @locale = locale
      I18n.locale = locale
    end

    def to_hash
      coupon = Monads::Optional.new(order.embedded_coupon)
      {
        id: order.id,
        order_no: order.order_no,
        payment_method: payment_method,
        created_at: order.created_at.strftime('%Y/%m/%d'),
        paid_at: order.paid_at.try(:strftime, '%Y/%m/%d'),
        approved_at: order.approved_at.try(:strftime, '%Y/%m/%d'),
        state: I18n.t("order.state.#{order.aasm_state}"),
        currency: order.currency,
        subtotal: order.subtotal,
        coupon_title: coupon.title.value,
        discount: order.discount,
        shipping_fee: order.shipping_fee,
        shipping_fee_discount: order.shipping_fee_discount,
        price: order.price,
        items: order_items,
        shipping_info: shipping_info,
        platform: order.platform,
        user_id: order.user_id
      }
    end

    private

    def paid_act
      order.activities.find_by(key: 'paid') ||
        order.activities.where(key: 'state_changed')
          .where("extra_info->>'state_change' = ?", %w(pending paid).to_json).first ||
        order.activities.where(key: 'state_changed')
          .where("extra_info->>'state_change' = ?", %w(waiting_for_payment paid).to_json).first
    end

    def shipping_info
      obj = order.shipping_info
      province = obj.address_data.province || obj.province.try(:name)
      city = obj.address_data.city || obj.city
      dist = obj.address_data.dist || obj.dist
      {
        name: obj.name,
        email: obj.email,
        phone: obj.phone,
        province: province,
        city: city,
        dist: dist,
        full_address: obj.full_address,
        shipped_at: order.shipped_at.try(:strftime, '%Y/%m/%d'),
        ship_company: ship_company,
        ship_code: order.ship_code
      }
    end

    def designer?(item)
      itemable = item.itemable
      itemable.is_a?(ArchivedStandardizedWork) || (itemable.is_a?(Work) && itemable.user_type == 'Designer')
    end

    def designer_name(item)
      monad = Monads::Optional.new(item)
      if monad.itemable.value.is_a? ArchivedStandardizedWork
        monad.itemable.original_work.user.display_name.value
      elsif monad.itemable.value.is_a? Work
        monad.itemable.user.display_name.value
      end
    end

    def coupon_base_price_type
      order.embedded_coupon.try(:base_price_type)
    end

    def order_items
      order.order_items.map do |item|
        model = product_model(item)
        next unless model
        original_price_unit = item.original_price_in_currency(order.currency)
        if item.discount.to_f > 0 && coupon_base_price_type == 'original'
          price_unit = original_price_unit
        else
          price_unit = item.price_in_currency(order.currency)
        end
        quantity = item.quantity
        subtotal = price_unit * quantity
        discount = item.try(:discount) # || (order.discount * subtotal / order.subtotal).round(1)
        sell_price = subtotal - discount.to_f
        real_price_unit = (sell_price / quantity).round(1)
        {
          product_category_key: model.category.key,
          product_category: model.category.name(@locale),
          product_model_key: model.key,
          product_model: model.name,
          is_remote: model.remote_key.present? ? :Y : :N,
          shop_or_custom: designer?(item) ? '設計師' : '客製化',
          designer: designer_name(item),
          work_name: item.itemable.name,
          original_price_unit: original_price_unit,
          price_unit: price_unit,
          real_price_unit: real_price_unit,
          quantity: quantity,
          subtotal: subtotal,
          discount: discount,
          shipping_fee: item.shipping_fee,
          sell_price: sell_price
        }
      end.compact
    end

    def ship_company
      if order.ship_code.to_s.start_with?('5')
        '圆通'
      elsif order.ship_code.to_s.start_with?('9')
        '顺丰'
      end
    end

    def payment_method
      alipay_payments = %w(pingpp_alipay pingpp_alipay_wap pingpp_alipay_qr pingpp_alipay_pc_direct)
      wx_payments = %w(pingpp_wx pingpp_wx_pub_qr)
      if order.payment_method.in? alipay_payments
        '支付宝'
      elsif order.payment_method.in? wx_payments
        '微信'
      else
        I18n.t("activerecord.attributes.order.payment_#{order.payment_method}")
      end
    end

    def product_model(item)
      monad = Monads::Optional.new(item)
      if monad.itemable.value.is_a? ArchivedWork
        monad.itemable.product.value || monad.itemable.original_work.product.value
      else
        monad.itemable.product.value
      end
    end
  end
end
