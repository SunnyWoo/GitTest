class Print::PackagesController < PrintController
  before_action :find_package, only: [:sf_express, :yto_express]

  def index
    authorize Package, :index?
    @package = Package.find_by(package_no: params[:package_no])
    @print_items = @package.print_items if @package
  end

  def create
    authorize Package, :create?
    if params[:package].present?
      Package.create_package_with_print_items(params[:package])
      redirect_to :back, notice: 'success'
    else
      redirect_to :back, alert: 'failed'
    end
  end

  def ship
    authorize Package, :ship?
    ship_form = Print::ShipForm.new(ship_params)
    if ship_form.ship!
      redirect_to :back, notice: 'success'
    else
      redirect_to :back, alert: ship_form.errors.full_messages.join(',')
    end
  end

  def sf_express
    authorize Package, :sf_express?
    @sf_result = SfExpress::Order.new(adapter).execute
    if @sf_result.key?('error') && @sf_result['error'].match(/重复下单|客户订单号\(orderid\)已存在/)
      @sf_result = SfExpress::OrderSearch.new(adapter).execute
    end
    @logistics_supplier = LogisticsSupplier.find_by_name('順豐')
  end

  def yto_express
    authorize Package, :sf_express?
    @package_service = YtoExpress::PackageService.new(@package)
    @response = @package_service.post
    @logistics_supplier = LogisticsSupplier.find_by(name: '圆通')
  end

  private

  def ship_params
    params.require(:print_ship_form).permit(:logistics_supplier_id, :ship_code, :invoice_number).merge!(package_id: params[:package_id])
  end

  def find_package
    @package = Package.find(params[:package_id])
  end

  def adapter
    @adapter ||= SfExpressAdapter.new(@package)
  end
end
