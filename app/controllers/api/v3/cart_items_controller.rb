=begin
@apiDefine CartItemResponse
@apiSuccessExample {json} Response-Example:
  {
    "status": "success",
    "cart": {
      "gid://command-p/Work/3490": 1,
      "gid://command-p/Work/3641": 2
    },
    "meta": {
      "items_count": 2
    }
  }
=end

class Api::V3::CartItemsController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :check_user

  before_action :find_cart
  before_action :check_quantity, only: [:create, :update]
  before_action :find_work

=begin
@api {post} /api/cart/items Create cart item
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Carts
@apiName CreateCartItems
@apiParam {Integer} work_id the work id
@apiParam {String} work_uuid the work uuid
@apiParam {Number{1-10}} quantity add quantity
@apiParamExample {json} Request-Example:
  {
    "work_id": 1,
    "quantity": 2,
  }
@apiUse CartItemResponse
=end
  def create
    @cart.add_items(@work.to_gid, @quantity)
    @cart.save
    render json: {
      status: :success,
      cart: @cart.items.as_json,
      meta: { items_count: @cart.items.count }
    }
  end

=begin
@api {put} /api/cart/items Update cart item
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Carts
@apiName UpdateCartItems
@apiParam {String} work_uuid the work uuid
@apiParam {Number{1-10}} quantity update quantity
@apiParamExample {json} Request-Example:
  {
    "work_uuid": ec5e3532-ad14-11e4-b602-3c15c2d24fd8,
    "quantity": 3,
  }
@apiUse CartItemResponse
=end
  def update
    @cart.update_items(@work.to_gid, @quantity)
    @cart.save
    render json: {
      status: :success,
      cart: @cart.items.as_json,
      meta: { items_count: @cart.items.count }
    }
  end

=begin
@api {delete} /api/cart/items Delete cart item
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Carts
@apiName DeleteCartItems
@apiParam {Integer} work_id the work id
@apiParam {String} work_uuid the work uuid
@apiParamExample {json} Request-Example:
  {
    "work_id": 1,
  }
@apiParamExample {json} Request-Example:
  {
    "work_uuid": ec5e3532-ad14-11e4-b602-3c15c2d24fd8,
  }
@apiUse CartItemResponse
=end
  def destroy
    @cart.delete_items(@work.to_gid)
    @cart.save
    render json: {
      status: :success,
      cart: @cart.items.as_json,
      meta: { items_count: @cart.items.count }
    }
  end

  protected

  def find_cart
    args = { controller: self, user_id: current_user.id }
    args[:store_id] = params[:store_id] if params[:store_id].present?
    @cart = CartSession.new(args)
  end

  def check_quantity
    @quantity = params[:quantity].to_i
    fail ParametersInvalidError, caused_by: :quantity if @quantity <= 0
  end

  def find_work
    @work = case
            when params[:gid]
              work = GlobalID::Locator.locate(params[:gid])
              fail ActiveRecord::RecordNotFound unless work
              work
            when params[:work_uuid]
              find_work_by_uuid(params[:work_uuid])
            when params[:work_id]
              StandardizedWork.find_by(id: params[:work_id]) || Work.find_by!(id: params[:work_id])
            else
              fail ApplicationError, 'No work_id or work_uuid provided.'
            end
  end

  def find_work_by_uuid(work_uuid)
    StandardizedWork.find_by(slug: work_uuid) || Work.find_by(slug: work_uuid) ||
      StandardizedWork.find_by(uuid: work_uuid) || Work.find_by!(uuid: work_uuid)
  end
end
