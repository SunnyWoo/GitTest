class Print::OrdersController < PrintController
  layout 'order', except: %w(deliver_orders schedule)

  before_action :display_list_method, only: :history
  before_action :find_order, only: %w(package update_invoice package_parting splice_order)

  def show
    @order = Order.includes(order_items: :itemable)
                  .includes(:print_items, :billing_info).find(params[:id])
  end

  def package
    authorize Order, :package?
    if @order.decorate.allow_package?
      print_item_ids = @order.print_items.unpackaged.pluck(:id)
      Package.create_package_with_print_items(print_item_ids: print_item_ids)
      flash[:notice] = '訂單打包完成。'
    else
      flash[:notice] = '訂單未完全熱轉印無法打包。'
    end
    redirect_to :back
  end

  def package_parting
    authorize Order, :package?
  end

  def splice_order
    authorize Order, :package?
    @orders = Order.includes(package_order_includes).paid.where(id: @order.merge_target_ids)
                   .joins(:shipping_info).order('billing_profiles.shipping_way DESC')
  end

  def update_invoice
    authorize Order, :update_invoice?
    @order.update! invoice_number: params[:order][:invoice_number]
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render json: { order: @order } }
    end
  end

  def history
    authorize Order, :history?
    @orders = Order.includes(order_items: :itemable).finish.order(shipped_at: :desc).page(params[:page])
    @orders = @orders.per_page(500) if @list == :simple
    respond_to do |format|
      format.html { render layout: 'print' }
      format.csv do
        headers['Content-Disposition'] = file_disposition('歷史訂單', 'csv')
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def sf_express_order
    authorize Order, :sf_express_order?
    @order = Order.find(params[:order_id])
    @sf_result = SfExpress::Order.new(@order).execute
    if @sf_result.key?('error') && @sf_result['error'].match(/重复下单|客户订单号\(orderid\)已存在/)
      @sf_result = SfExpress::OrderSearch.new(@order).execute
    end
  end

  def barcode
    @order = Order.find(params[:id])
  end

  def deliver_orders
    @orders = Order.includes(:print_items).where(aasm_state: %w(paid packaged)).where.not(remote_id: nil).order('approved_at')
  end

  def schedule
    authorize Order, :schedule?
    @schedule_presenter = Print::OrderPrintSchedulePresenter.new(params)
  end

  def disable_schedule
    authorize Order, :disable_schedule?
    @order = Order.find(params[:id])
    @order.disable_schedule
  end

  private

  def find_order
    @order = Order.find(params[:order_id])
  end

  def display_list_method
    @list = params[:list].present? ? params[:list].to_sym : :normal
  end

  def package_order_includes
    print_items_includes = { order_item: [:itemable], product: [:translations], temp_shelf: [] }
    { notes: [:user], shipping_info: [], billing_info: [], print_items: print_items_includes }
  end
end
