class Admin::AdjustmentsController < AdminController
  def create
    order = Order.find(params[:order_id])
    if order.adjustments.create(admin_permitted_params.adjustment.merge(source: current_admin, event: Adjustment.events['manual'], adjustable: order))
      redirect_to :back, flash: { success: I18n.t('orders.adjustment_creation.create_success') }
    else
      redirect_to :back, flash: { alert: I18n.t('orders.adjustment_creation.create_fail') }
    end
  end
end
