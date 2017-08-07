class Api::V3::DeliverOrder::OrderItemsController < ApiV3Controller
  before_action :doorkeeper_authorize!

  # 支援抛单order_item重新取图片链接
  def show
    order_item = OrderItem.find_by!(id: params[:id])
    render json: order_item.china_archive_attributes, status: :ok
  end
end
