class OrderMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  add_template_helper(CartHelper)

  layout 'order_mail'

  after_action :check_order_notifiable

  def receipt(user_id, order_id, locale = 'en')
    @user = User.find(user_id)
    @order = Order.includes(:billing_info, :shipping_info, :order_items).find(order_id)
    @order = OrderDecorator.new(@order)
    @billing_info = @order.billing_info
    @shipping_info = @order.shipping_info
    @fee = Fee.where(name: '運費').first
    I18n.with_locale(locale) do
      email = mail to: @billing_info.email, subject: I18n.t('email.order.receipt.subject')
      email.mailgun_variables = { 'order_no' => @order.order_no }
    end
  end

  def receipt_with_status(user_id, order_id, locale = 'en')
    @user = User.find(user_id)
    @order = Order.includes(:billing_info, :shipping_info, :order_items).find(order_id)
    @billing_info = @order.billing_info
    @shipping_info = @order.shipping_info
    @fee = Fee.where(name: '運費').first
    @cash_on_delivery = Fee.find_by(name: 'cash_on_delivery').price_in_currency('TWD')
    I18n.with_locale(locale) do
      email = mail to: @billing_info.email, subject: I18n.t('email.order.receipt_with_status.subject')
      email.mailgun_variables = { 'order_no' => @order.order_no }
    end
  end

  def download(user_id, order_id, locale = 'en')
    @user = User.find(user_id)
    @order = Order.find(order_id)
    @billing_info = @order.billing_info

    # 判斷 PorductModel 包含 case or cover 才寄 Mail
    is_send_mail = false
    @order.order_items.each { |oi| is_send_mail = true if oi.itemable.product.key.match(/case|cover/) }

    if is_send_mail
      I18n.with_locale(locale) do
        email = mail to: @billing_info.email, subject: I18n.t('email.order.download.subject')
        email.mailgun_variables = { 'order_no' => @order.order_no }
      end
    end
  end

  def ship(user_id, order_id, locale = 'en')
    @user = User.find(user_id)
    @order = Order.includes(:billing_info, :shipping_info).find(order_id)
    @shipping_info = @order.shipping_info
    @billing_info = @order.billing_info
    @today = I18n.l(Time.zone.today)
    I18n.with_locale(locale) do
      email = mail to: @billing_info.email, subject: I18n.t('email.order.ship.subject')
      email.mailgun_variables = { 'order_no' => @order.order_no }
    end
  end

  def conflict_warning(order_id, locale = 'en')
    @order = Order.find(order_id)
    I18n.with_locale(locale) do
      email = mail to: Settings.mailgun.mailing_list.customer_service, subject: I18n.t('email.order.conflict.subject')
      email.mailgun_variables = { 'order_no' => @order.order_no }
    end
  end

  def payment_remind(order_id, locale = 'en')
    @order = Order.find(order_id)
    I18n.with_locale(locale) do
      email = mail to: @order.billing_info.email, subject: I18n.t('email.order.payment_remind.subject')
      email.mailgun_variables = { 'order_no' => @order.order_no }
    end
  end

  def check_order_notifiable
    mail.perform_deliveries = false unless @order.notifiable?
  end

  def store_receipt(user_id, order_id, locale = 'en')
    @user = User.find(user_id)
    @order = Order.includes(:billing_info, :shipping_info, :order_items).find(order_id)
    @order = OrderDecorator.new(@order)
    @store = Store.find @order.channel
    @shipping_info = @order.shipping_info
    @fee = Fee.where(name: '運費').first
    I18n.with_locale(locale) do
      email = mail(to: @shipping_info.email, subject: I18n.t('email.order.store_receipt.subject', name: @store.name)) do |format|
        format.html { render layout: 'store_order_mail' }
      end
      email.mailgun_variables = { 'order_no' => @order.order_no }
    end
  end
end
