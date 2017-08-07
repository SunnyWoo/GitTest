class Print::BatchFlowsController < PrintController
  before_action :find_external_product_models, only: :index
  before_action :find_batch_flow, only: [:destroy, :history, :start]

  # 包含 external_code 的 ProductModel 才需要使用 batch upload
  def index
    @batch_flows = BatchFlow.includes(:factory, :attachments).order('created_at DESC').page(params[:page])

    q = { order_item_order_aasm_state_eq: 'paid',
          aasm_state_eq: 'pending',
          model_id_in: @product_models.pluck(:id) }

    @pending_print_items = PrintItem.joins(order_item: :order).pending.ransack(q).result
    @group_print_items = @pending_print_items.select('print_items.model_id, count(print_items.id) count').group(:model_id)
    @defualt_batch_deadline = (Time.zone.now + BatchFlow::BATCH_DELAY_DAYS.day).strftime("%Y-%m-%d %H%M")
  end

  def show
    redirect_to print_batch_flows_path
  end

  def create
    batch_flow = BatchFlow.new(batch_flow_params)
    log_with_admin_or_print(batch_flow)
    if batch_flow.save && batch_flow.initial!
      flash[:notice] = '新增成功'
    else
      flash[:error] = batch_flow.errors.full_messages
    end
    redirect_to print_batch_flows_path
  end

  def destroy
    if @batch_flow.cancel!
      flash[:notice] = '重置成功'
    else
      flash[:error] = batch_flow.errors.full_messages
    end
    redirect_to print_batch_flows_path
  end

  def start
    @batch_flow.start!
    redirect_to print_batch_flows_path, notice: '開始批次上傳'
  rescue => e
    redirect_to print_batch_flows_path, error: e.message
  end

  def history
    @activities = @batch_flow.activities.ordered.page(params[:page])
  end

  private

  def batch_flow_params
    params.require(:batch_flow).permit(:deadline, :factory_id, :locale, product_model_ids: [])
  end

  def find_batch_flow
    @batch_flow = BatchFlow.find(params[:id])
    log_with_admin_or_print(@batch_flow)
  end

  def find_external_product_models
    @product_models = ProductModel.with_external_code
  end
end
