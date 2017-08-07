class Admin::DeliverOrdersController < AdminController
  def index
    q = params[:q] || {}
    q[:delivered_at_null] = 0
    @q = Order.ransack(q)
    @orders = @q.result.order('delivered_at DESC').page(params[:page])
  end

  def deliver_failed
    q = params[:q] || { aasm_state_eq: 'failed' }
    @q = DeliverErrorCollection.ransack(q)
    @error_collections = @q.result.includes(:order, :workable).order(created_at: :desc).page(params[:page])
  end

  def repair_images
    DeliverErrorCollection.find(params[:error_id]).repair_images_sync
    redirect_to :back, notice: 'repairing'
  end
end
