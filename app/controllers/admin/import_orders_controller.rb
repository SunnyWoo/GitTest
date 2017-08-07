class Admin::ImportOrdersController < AdminController
  def index
    @import_orders = ImportOrder.all.order(created_at: :desc).page(params[:page]).includes(succeeds: :order)
    @new_import = ImportOrder.new
  end

  def create
    @order_import = ImportOrder.new(create_params)
    if @order_import.save
      flash[:notice] = 'success'
    else
      flash[:alert] = @order_import.errors.full_messages
    end
    redirect_to admin_import_orders_path
  end

  def retry
    @import_order = ImportOrder.find(params[:import_order_id])
    @import_order.failed_retry_sync
    redirect_to admin_import_orders_path, notice: 'success'
  end

  private

  def create_params
    params.require(:import_order).permit(:file)
  end
end
