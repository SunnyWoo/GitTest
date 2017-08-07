class Admin::DashboardsController < AdminController
  def watching_order
    @orders = Order.watching.page(params[:page])
  end
end
