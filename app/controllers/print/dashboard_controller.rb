class Print::DashboardController < PrintController
  before_action :find_category, only: [:index, :sublimate]
  before_action :find_model, only: [:index, :sublimate]
  before_action :check_ftp_status, only: [:index]

  def index
    q = params[:q] || {}
    aasm_state_eq = params[:aasm_state] || 'pending'
    q.merge!(order_item_order_aasm_state_eq: 'paid',
             aasm_state_eq: aasm_state_eq,
             model_id_eq: @model.id)
    @search = PrintItem.includes(order_item: :order).ransack(q)
    @print_items = @search.result.order(:prepare_at)
  end

  def sublimate
    @list = params[:list] || 'normal'
    q = params[:q] || {}
    q.merge!(order_item_order_aasm_state_eq: 'paid', aasm_state_eq: 'printed')
    q.merge!(model_id_eq: @model.id) if @list == 'normal'
    @search = PrintItem.includes(order_item: :itemable).ransack(q)
    @print_items = @search.result.order(:print_at).decorate
    respond_to do |format|
      format.html
      format.csv do
        send_data mark_csv_data(PrintService.export_sublimate_csv(@print_items)),
                  disposition: file_disposition('熱轉印简易列表', 'csv')
      end
    end
  end

  def temp_shelf
    @list = params[:list] || 'normal'
    @page_mode = (@list == 'normal') # 只在普通列表有分頁
    orders = Order.includes(:notes, :shipping_info, :print_items,
                            order_items: [:notes, :itemable,
                                          print_items: [:temp_shelf, product: :translations]])
                  .paid.ransack(temp_shelf_params).result.order('orders.approved_at')
    group_orders = orders.group('orders.id')
    @orders = @page_mode ? group_orders.page(params[:page]).decorate : group_orders.decorate
    @orders_count = orders.count
    respond_to do |format|
      format.html
      format.csv { csv_headers('质检区简易列表') }
    end
  end

  def package
    if params[:q].present?
      search_orders_for_package(params[:q])
    else
      list_orders_for_package
    end
    respond_to do |format|
      format.html
      format.csv { csv_headers('包裝简易列表') }
    end
  end

  def ship
    if params[:q].present?
      search_packages_for_ship(params[:q])
    else
      list_packages_for_ship
    end
    @logistics_suppliers = LogisticsSupplier.order(:position)
    respond_to do |format|
      format.html
      format.csv { csv_headers('出货简易列表') }
    end
  end

  def search
    authorize Order, :search?
    redirect_to print_print_path unless params[:q].present?
    # 可以通过print_item的code 或 print_item.timestamp_no搜索
    @print_items = PrintItem::CodeQuery.new(params[:q]).result
    @order = Order.find_by(order_no: params[:q]) if @print_items.blank?
  end

  def log
    @activities = Logcraft::Activity.print.page(params[:page])
  end

  private

  def find_category
    current_factory_category_ids = current_factory.product_models.pluck(:category_id).uniq
    @categories = ProductCategory.includes(:translations).where(id: current_factory_category_ids)
    @category = if params[:category_id].present?
                  @categories.find(params[:category_id])
                else
                  @categories.first
                end
    render 'index_blank_state' unless @category
  end

  def find_model
    @factory_product_models_with_category =
      current_factory.product_models.includes(:translations).where(category_id: @category.id) if @category

    @model = if params[:model_id].present?
               current_factory.product_models.find(params[:model_id])
             elsif @category
               @category.products.first
             end
  end

  def check_ftp_status
    @ftp_service_status = current_factory.ftp_gateway.try(:check_server) || 0
  end

  def temp_shelf_params
    search = { print_items_aasm_state_in: %w(delivering received sublimated) }
    if params[:timestamp_no].present?
      timestamp_no = PrintItem::CodeHandler.decode(params[:timestamp_no])
      search.merge!(order_items_print_items_timestamp_no_or_order_no_eq: timestamp_no)
    end
    search
  end

  def package_order_includes
    product_includes = { product: [:translations] }
    order_items_includes = { itemable: product_includes, print_items: product_includes, notes: [:user] }
    { notes: [:user], shipping_info: [], billing_info: [], order_items: order_items_includes, print_items: [] }
  end

  def ship_package_includes
    { print_items: { order_item: [:itemable], product: [:translations] } }
  end

  def search_packages_for_ship(q)
    @list = 'normal' # 搜尋時只有普通列表的程現
    @page_mode = false # 搜尋時不分頁
    @search = PrintItem.ransack(timestamp_no_eq: q)
    if @search.result.size > 0
      print_item = @search.result.first
      package = print_item.package
      @packages = package.try(:onboard?) ? [package.decorate] : []
    else
      @packages = Package.onboard.ransack(orders_order_no_eq: q, package_no_eq: q, m: 'or').result.distinct('packages.id').decorate
    end
    @packages_count = @packages.count
  end

  def search_orders_for_package(q)
    search_orders_with_state(q, :paid)
  end

  def search_orders_with_state(q, state)
    @list = 'normal' # 搜尋時只有普通列表的程現
    @page_mode = false # 搜尋時不分頁
    @search = PrintItem.ransack(timestamp_no_eq: q, aasm_state_in: %w(qualified received))
    if @search.result.size > 0
      print_item = @search.result.first
      order = print_item.order
      @orders = order.send("#{state}?") ? [order.decorate] : []
    else
      @orders = Order.send(state).where(order_no: q).ransack(print_items_aasm_state_in: %w(qualified received)).result.group('orders.id').decorate
    end
    @orders_count = @orders.count
  end

  def list_packages_for_ship
    @packages = Package.includes(ship_package_includes).onboard
    @list = params[:list] || 'normal' # 簡易(simple) 或 普通(normal)
    @page_mode = (@list == 'normal') # 只在普通列表有分頁
    @packages = @packages.page(params[:page]) if @page_mode
    @packages = @packages.decorate
    @packages_count = @packages.size
  end

  def list_orders_for_package
    orders = Order.paid.includes(package_order_includes).order('approved_at')
                  .ransack(print_items_aasm_state_in: %w(qualified received)).result
    setup_list_variables(orders)
  end

  def setup_list_variables(orders)
    @list = params[:list] || 'normal' # 簡易(simple) 或 普通(normal)
    @page_mode = (@list == 'normal') # 只在普通列表有分頁
    orders = orders.page(params[:page]) if @page_mode
    @orders = orders.group('orders.id').decorate
    @orders_count = orders.count
  end

  def csv_headers(filename)
    headers['Content-Disposition'] = file_disposition(filename, 'csv')
    headers['Content-Type'] ||= 'text/csv'
  end
end
