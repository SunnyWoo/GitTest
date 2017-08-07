class Print::ExportOrdersController < PrintController
  def index
    @export_orders = ExportOrder.all.order(created_at: :desc).page(params[:page])
  end
end
