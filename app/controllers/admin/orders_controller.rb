class Admin::OrdersController < Admin::ResourcesController
  before_action :find_order, only: [:watch, :unwatch, :invoice_required, :cancel_invoice]

  def index
    @search = model_class.ransack(params[:q])
    @resources = @search.result.includes(order_items: [itemable: [:previews]])
                        .includes(:coupon, :billing_info, :shipping_info)
                        .order('created_at DESC')
                        .page(params[:page])
  end

  def show
    @resource = Order.find(params[:id])
    @promotions = Promotion.available.select { |p| p.order_eligible?(@resource) }
    @country_code_by_ip = country_code_by_ip(@resource.ip)
    @refund_button_name = %w(stripe paypal).include?(@resource.payment) ? I18n.t('orders.show.exec_refund') : I18n.t('orders.show.create_refund_record')
  end

  def index_init
    render json: {
      search_input: {
        key: :search,
        placeholder: 'starting typing to search（include order no., phone no., ship id and Email）'
      },
      filter: [
        {
          name: 'Order Status',
          key: :aasm_state,
          values: Order.aasm.states.map { |s| { key: s.name, name: s.localized_name } }
        }, {
          name: 'Payment',
          key: :payment,
          values: Order.payments.map { |p| { key: p, name: t("activerecord.attributes.order.payment_#{p}") + "(#{p})" } }
        }, {
          name: 'Destination',
          key: :billing_info_country_code,
          values: BillingProfile.countries_with_country_code.map { |k, v| { key: v, name: k } }
        }, {
          name: 'Platform',
          key: :platform,
          values: %w(web iOS android).map { |c| { key: c, name: c } }
        }, {
          name: 'Production Status',
          key: :work_states,
          values: Order.work_states.keys.map { |w| { key: w, name: I18n.t("order.work_state.#{w}") } }
        }, {
          name: 'Created Date',
          key: :created_at,
          values: [
            {
              key: Time.zone.today.beginning_of_day..Time.zone.today.end_of_day,
              name: 'Today'
            }, {
              key: Time.zone.yesterday.beginning_of_day..Time.zone.yesterday.end_of_day,
              name: 'Yesterday'
            }, {
              key: 1.week.ago.at_beginning_of_week.beginning_of_day..1.week.ago.at_end_of_week.end_of_day,
              name: 'Last Week'
            }, {
              key: 1.month.ago.at_beginning_of_month.beginning_of_day..1.month.ago.at_end_of_month.end_of_day,
              name: 'Last month'
            }, {
              key: 7.days.ago.beginning_of_day..Time.zone.today.end_of_day,
              name: 'Last 7 days'
            }, {
              key: 30.days.ago.beginning_of_day..Time.zone.today.end_of_day,
              name: 'Last 30 days'
            }
          ]
        }, {
          name: 'Flags',
          key: :flags,
          values: Order::ORDER_FLAG_TYPES.map { |flag| { key: flag.to_s, name: I18n.t("orders.show.flags.#{flag}") } }
        }
      ], thead: [
        { text: t('orders.index.thead.order_no'), sort: 'order_no' },
        { text: t('orders.index.thead.cover_img') },
        { text: t('orders.index.thead.order_state'), sort: 'aasm_state' },
        { text: t('orders.index.thead.flags') },
        { text: t('orders.index.thead.order_created_at'), sort: 'created_at' },
        { text: t('orders.index.thead.order_amount_nt'), sort: 'price' },
        { text: t('orders.index.thead.ship'), sort: 'shipping_info_shipping_way' },
        { text: t('orders.index.thead.destination'), sort: 'shipping_info_country' }
      ]
    }
  end

  def search
    @page = [params[:page].to_i, 1].max
    respond_to do |format|
      format.html do
        @search = model_class.ransack(params[:q])
        @resources = @search.result.page(@page)
        render :index
      end
      format.json do
        s = admin_permitted_params.order_search if params[:order_search]
        q = {}
        unless s.nil?
          if s[:search]
            filter = %w(order_no billing_info_phone ship_code
                        billing_info_email coupon_title coupon_code)
            filter = (filter.join('_or_') + '_cont').to_sym
            q[filter] = s[:search]
          end
          if s[:s].present?
            q[:s] = s[:s]
            s.delete('s')
          end
          if s[:created_at].present?
            q[:created_at_gteq] = s[:created_at].split('..').first
            q[:created_at_lteq] = s[:created_at].split('..').last
            s.delete('created_at')
          end
          if s[:platform].present? && s[:platform] == 'web'
            q[:platform_not_in] = %w(iOS android)
            s.delete('platform')
          end
          if s[:coupon].present?
            q[:coupon_title_or_coupon_code_eq] = s[:coupon]
            s.delete('coupon')
          end
          s.each do |k, v|
            next unless v.present?
            next if k == 'flags'
            if v.split(',').size == 1
              q["#{k}_eq"] = v
            else
              q["#{k}_in"] = v.split(',')
            end
          end
        end
        flags = s.try(:fetch, :flags, nil) ? s[:flags].split(',').map(&:to_sym) : []
        orders_relations = flags.present? ? Order.with_flags(*flags) : Order
        @search = orders_relations.ransack(q)
        @orders = @search.result
                         .includes(order_items: [itemable: [:previews]])
                         .includes(:coupon, :billing_info, :shipping_info)
                         .page(@page).decorate(with: Admin::OrderDecorator)
        render 'admin/orders/search'
      end
    end
  end

  def refund
    @order = Order.find(params[:order_id])
    log_with_current_admin @order
    payment = case @order.payment
              when 'paypal'
                "#{@order.payment}_service".camelize.constantize.new(@order)
              when 'stripe'
                Stripe::RefundService.new(@order)
              when *Order::PAYMENTS_CHINA
                PingppService.new(@order)
              else
                @order.payment_object
              end
    price = params[:order][:price]
    note = params[:order][:refund_memo]
    begin
      if (@order.payment != 'stripe' && payment.refund(price, note: note)) ||
         (@order.payment == 'stripe' && payment.execute(price, note))
        message = @order.pingpp_alipay_payment? ? @order.errors.messages[:failure_msg].first.to_s : nil
        create_refund(price, message)
      else
        create_refund_fail(price, @order.errors.messages)
      end
    rescue Payment::NegativeRefundError, Payment::InvalidRefundError => e
      create_refund_fail(price, e.message)
    end
  end

  def history
    @order = Order.find(params[:order_id])
    @versions = PaperTrail::Version
                .where('(item_type = ? AND item_id = ? ) OR (item_type = ? AND item_id in (?) )',
                       'Order', @order.id,
                       'BillingProfile', [@order.billing_info.id, @order.shipping_info.id])
                .order('id DESC')
                .page(params[:page])
  end

  def paypal_sale_id
    @order = Order.find(params[:order_id])
  end

  def unapproved
    if params[:q] && shipping_way = params[:q]['shipping_info_shipping_way_in']
      params[:q]['shipping_info_shipping_way_in'] = shipping_way.split(',')
    end
    @search = Order.paid.unapproved.ransack(params[:q])
    @resources = @search.result.order('created_at ASC').page(params[:page]).decorate(with: Admin::OrderDecorator)
    respond_to do |format|
      format.html
      format.json { @orders = @resources }
    end
  end

  def unapproved_counts
    render json: {
      standard: Order.paid.unapproved.ransack(shipping_info_shipping_way_in: [0, 2]).result.count,
      express: Order.paid.unapproved.ransack(shipping_info_shipping_way_in: [1]).result.count
    }
  end

  def approve
    @order = Order.find(params[:order_id])
    log_with_current_admin @order
    return @error_message = 'Error:存在無Print Image的work' unless @order.all_print_image_exist?
    if @order.approve!
      @message = "訂單編號：#{@order.order_no} 通過審核。"
    else
      @error_message = "Error:#{@order.errors.full_messages.join(',')}"
    end
  rescue ActiveRecord::StaleObjectError
    @error_message = "訂單編號：#{@order.order_no} 操作异常, 请刷新后重试"
  end

  def approve_invoice
    params[:q] = params[:q] || { s: 'id asc', invoice_state_in: ['0'] }
    @search = Order.shipping.should_invoices.ransack(params[:q])
    @resources = @search.result.includes(:shipping_info).page(params[:page])
  end

  def approve_invoice_activities
    @activities = Logcraft::Activity.invoice.order('id DESC').page(params[:page])
    render 'admin/activities/index'
  end

  def edit
    @order = Order.find(params[:id])
  end

  def edit_ship
    @order = Order.find(params[:order_id])
  end

  def update_shipping_info
    @order = Order.find(params[:order_id])
    log_with_current_admin @order
    ship_code_was = @order.ship_code_was || 'none'
    shipping_way_was = @order.shipping_info_shipping_way
    if @order.update_attributes(admin_permitted_params.order)
      @order.create_activity(:update_shipping_info, ship_code_was: ship_code_was,
                                                    ship_code: @order.ship_code,
                                                    shipping_way_was: shipping_way_was,
                                                    shipping_way: @order.shipping_info_shipping_way)
      redirect_to admin_order_path(@order), flash: { success: '更新成功!' }
    else
      redirect_to admin_order_path(@order), flash: { error: @order.errors.full_messages }
    end
  end

  def update
    @resource = model_class.find(params[:id])
    log_with_current_admin @resource
    if @resource.update_attributes(admin_permitted_params.order)
      respond_to do |format|
        format.html { redirect_to admin_order_path(@resource), flash: { success: '更新成功!' } }
        format.json do
          render json: {
            status: 'ok',
            message: "OrderID:#{@resource.id} 更新成功",
            id: @resource.id
          }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to admin_order_path(@resource), flash: { error: @resource.errors.full_messages } }
        format.json do
          render json: {
            status: 'error',
            message: "OrderID:#{@resource.id} #{@resource.errors.full_messages}"
          }
        end
      end
    end
  end

  def send_receipt
    email = admin_permitted_params.order[:billing_info][:email]
    @resource = model_class.find(params[:order_id])
    @resource.billing_info.update_attribute(:email, email) if email.present?
    log_with_current_admin @resource
    @resource.create_activity(:force_send_receipt, change_email: email)
    if @resource.waiting_for_payment?
      ReceiptWithStatusSender.perform_async(@resource.id)
    elsif @resource.receipt_deliverable?
      ReceiptSender.perform_async(@resource.id)
    end
    flash[:notice] = t('orders.toolbar.notice')
    redirect_to admin_order_path(@resource)
  end

  def batch_update
    @resources = model_class.find(params[:ids])
    ok = []
    error = []
    @resources.each do |order|
      log_with_current_admin order
      if order.update_attributes(admin_permitted_params.send(:order))
        ok << order.id
      else
        error << "更新失敗 OrderId:#{order.id} Message:#{order.errors.full_messages}"
      end
    end
    render json: {
      ok: { message: '更新成功', ids: ok },
      error: error
    }
  end

  def invoice_upload
    InvoiceService.logcraft(:invoice_upload, nil, admin_id: current_admin.id)
    orders = Order.should_invoices.invoice_ready_upload
    res = InvoiceService.check_upload_data(orders)
    if res[:status]
      if InvoiceService.data_to_bankpro(orders)
        flash[:notice] = '上傳發票資訊成功'
      else
        flash[:error] = '上傳發票資訊失敗'
      end
    else
      flash[:error] = res[:messages]
    end
    redirect_to approve_invoice_admin_orders_path(q: { invoice_state_eq: Order.invoice_states['invoice_ready_upload'] })
  end

  def invouce_check
    if Order.invoice_uploading.count > 0 || Order.invoice_uploaded.count > 0
      InvoiceService.download_bankpro_file
      flash[:notice] = '已更新發票資訊'
    end
    redirect_to request.referer || approve_invoice_admin_orders_path
  end

  def update_remote_info
    order = Order.find(params[:order_id])
    return redirect_to admin_order_path(order) unless order.delivered?
    remote_info_service = DeliverOrder::RemoteInfoService.new(order)
    if remote_info_service.update
      flash[:notice] = '更新成功'
    else
      flash[:error] = remote_info_service.errors.full_messages.unshift('更新失败:')
    end
    redirect_to :back
  end

  def unlock
    order = Order.find(params[:order_id])
    order.unlocked! if order.locked?
    redirect_to :back
  end

  def unwatch
    @order.unwatch
    render nothing: true
  end

  def watch
    @order.watch
    render nothing: true
  end

  def invoice_required
    @order.update_column(:invoice_required, true)
    render nothing: true
  end

  def cancel_invoice
    @order.update_column(:invoice_required, false)
    render nothing: true
  end

  private

  def create_refund_fail(price, error_message)
    @order.create_activity(:refund_fail, price: price, error_message: error_message)
    redirect_to request.referer || admin_orders_path, flash: { error: error_message }
  end

  def create_refund(price, message = nil)
    @order.create_activity(:refund, price: price, message: message)
    more_notice = @order.pingpp_alipay_payment? ? '請從動態中的退款連結進行退款!' : ''
    redirect_to admin_order_path(@order), flash: {
      notice: "訂單編號:#{@order.order_no}, #{@order.payment.capitalize} 退款成功！#{more_notice}" }
  end

  def find_order
    @order = Order.find(params[:id])
  end
end
