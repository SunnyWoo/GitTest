class Api::V3::DeliverOrder::RemoteInfosController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :find_order, only: :show
  before_action :remote_response, only: :show

  def index
    remote_ids = Order.where(remote_id: params[:remote_ids]).pluck(:remote_id)
    render json: { remote_ids: remote_ids }, status: :ok
  end

  def show
    render json: @remote_response, status: :ok
  end

  def update
    @order = Order.find(params[:remote_id])
    @order.update_remote_info(params[:remote_info])
    render json: { status: true }
  rescue => e
    render json: { status: false, error: e.to_s }
  end

  private

  def find_order
    @order = Order.find_by!(remote_id: params[:remote_id])
  end

  def remote_response
    @remote_response = {
      'order_id' => @order.id,
      'remote_id' => @order.remote_id,
      'work_state' => @order.work_state,
      'aasm_state' => @order.aasm_state,
      'order_no' => @order.order_no,
      'order_items' => []
    }
    @order.order_items.each do |order_item|
      @remote_response['order_items'] << {
        'id' => order_item.remote_id,
        'aasm_state' => order_item.aasm_state
      }
    end
  end
end
