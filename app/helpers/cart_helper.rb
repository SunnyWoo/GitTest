module CartHelper
  def render_payment_redeem
    t('email.order.receipt.free')
  end

  def render_item_price(item, currency_code: current_currency_code)
    render_price(item.price_in_currency(currency_code), currency_code: currency_code)
  end

  def render_item_original_price(item, currency_code: current_currency_code)
    render_price(item.original_price_in_currency(currency_code), currency_code: currency_code)
  end

  def render_item_price_with_quantity(item, currency_code: current_currency_code)
    render_price(item.price_in_currency(currency_code) * item.quantity, currency_code: currency_code)
  end

  def render_item_original_price_with_quantity(item, currency_code: current_currency_code)
    render_price(item.original_price_in_currency(currency_code) * item.quantity, currency_code: currency_code)
  end

  def render_subtotal(order)
    render_order_price(order)
  end

  def render_order_price(order)
    return render_payment_redeem if order.payment == 'redeem'
    render_price(order.price, currency_code: order.currency)
  end

  def shipping_way_radio_list(shipping_way_list)
    content_tag(:ul) do
      shipping_way_list.each do |shipping_way, key|
        label_name = "shipping_way_#{shipping_way}".to_sym
        fee = Fee.where(name: shipping_way).first
        fee = fee ? render_price(fee.price_in_currency(current_currency_code)) : 'Free'

        html = radio_button_tag(:shipping_way, shipping_way)
        html += label_tag(label_name, t("shipping_info.shipping_way.#{shipping_way}"))
        html += label_tag(label_name, fee)
        concat content_tag(:li, html)
      end
    end
  end

  def render_shipping_way_fee(shipping_way)
    fee = Fee.where(name: shipping_way).first
    render_price(fee.price_in_currency(current_currency_code)) if fee.present?
  end

  def render_current_user_address_info
    if user_signed_in?
      content_tag(:ul) do
        current_user.address_info.each do |address, key|
          address_name = address.address_name
          label_name = "shipping_way_#{address_name}".to_sym
          html = radio_button_tag(:shipping_way, address)
          html += label_tag(label_name, t("shipping_info.shipping_way.#{address_name}"))
          concat content_tag(:li, html)
        end
      end
    end
  end

  def begin_payment_path(payment_method, params = {})
    case payment_method
    when 'paypal'           then begin_payment_paypal_path(params)
    when 'cash_on_delivery' then begin_payment_cash_on_delivery_path(params)
    when 'neweb/atm'        then begin_payment_neweb_atm_path(params)
    when 'neweb/mmk'        then begin_payment_neweb_mmk_path(params)
    when 'neweb/alipay'     then begin_payment_neweb_alipay_path(params)
    when 'neweb_mpp'        then begin_payment_neweb_mpp_path(params)
    when 'stripe'           then begin_payment_stripe_path(params)
    when 'pingpp_alipay_qr' then begin_payment_pingpp_alipay_qr_path(params)
    end
  end

  def render_cart_items
    count = 0
    if user_signed_in?
      cart = CartSession.new(controller: controller, user_id: current_user.id)
      count = cart.item_sum.to_i
      count = '99+' if count > 99
    end
    count.to_i > 0 ? content_tag(:div, count, class: 'cart-items-count') : ''
  end

  def render_repayment(order)
    if order.pending?
      payment_method_name = t("activerecord.attributes.order.payment_#{order.payment_method}")
      content_tag(:a, "Pay with #{payment_method_name}", class: 'btn btn-default',
                  href: begin_payment_path(order.payment, order_no: order.order_no), data: { method: 'post' })
    end
  end

  def show_payment_id_for_user(order)
    case order.payment
    when 'neweb/atm'
      html = "#{t('page.order_results.bank_id')}#{order.payment_object.bank_id}, #{t('page.order_results.bank_account')}#{order.payment_info['payment_id']}"
    when 'neweb/mmk'
      html = "#{t('page.order_results.pay_account')}#{order.payment_info['payment_id']}"
    when 'neweb/alipay'
      html = "#{t('page.order_results.bank_account')}#{order.payment_info['payment_id']}"
    else
      html = ''
    end

    content_tag(:span, html, class: 'payment-way')
  end

  def last_use_address_info_id(to_class)
    to_class = to_class.gsub(/order_/,'')
    if !current_user.last_order.nil? && current_user.last_order.send(to_class)
      current_user.last_order.send(to_class).from_address_info_id.to_i
    else
      0
    end
  end

  def check_select_address_info(last_use_address_info_id, address_info)
    if last_use_address_info_id > 0
      select_address_info = true if last_use_address_info_id.to_i == address_info.id.to_i
    else
      select_address_info = true
    end
  end

  def render_work_path(work)
    if work.is_a? ArchivedWork
      archived_work_path(work)
    else
      shop_work_path(work.product, work)
    end
  end

  def payment_hide_class(payment, order)
    if payment == 'cash_on_delivery' && order.shipping_info_country != 'Taiwan'
      'hide'
    elsif payment != 'pingpp_alipay_qr' && Region.china?
      'hide'
    else
      ''
    end
  end

  def render_shipping_price(order, currency = nil)
    currency = currency || order.currency
    order.shipping_price.to_i == 0 ? t('text.free') : render_price(order.shipping_price, currency_code: currency)
  end
end
