#
# 2014-10-22 測試後沒有在使用 By Rich
#
class Api::V1::My::ItemsController < ApiController
  before_action :find_order

  def create
    @item = @order.items.build(api_permitted_params.order_item)
    if @item.save
      render json: @item, root: false
    else
      render json: { message: "Error", error: @item.errors.full_messages }
    end
  end

  private

  def find_order
    @order = current_user.unfinish_orders.where(uuid: params[:order_uuid]).first
  end
end
