=begin
@apiDefine OrderResponse
@apiSuccessExample {json} Success-Response:
  {
    "order": {
      "uuid": "ec5e3532-ad14-11e4-b602-3c15c2d24fd8",
      "price": 30.95,
      "currency": "USD",
      "status": "Paid",
      "payment": "cash_on_delivery",
      "payment_info": {
        "payment_method": "cash_on_delivery"
      },
      "coupon": "",
      "order_price": {
        "subtotal": "29.95",
        "discount": "0.0",
        "shipping_fee": "1.0",
        "price": 30.95
      },
      "order_no": "1525284748TW",
      "billing_info": {
        "address": "0430 Schuppe LightsApt. 891",
        "city": "South Connie",
        "name": "Keith Dicki Jr.",
        "phone": "+886910000123",
        "state": "Kansas",
        "zip_code": "106",
        "country": "Taiwan",
        "created_at": "2015-02-05T16:56:51.242+08:00",
        "updated_at": "2015-02-05T16:56:51.242+08:00",
        "country_code": "TW",
        "email": "test@commandp.me"
      },
      "shipping_info": {
        "address": "0430 Schuppe LightsApt. 891",
        "city": "South Connie",
        "name": "Keith Dicki Jr.",
        "phone": "+886910000123",
        "state": "Kansas",
        "zip_code": "106",
        "country": "Taiwan",
        "created_at": "2015-02-05T16:56:51.252+08:00",
        "updated_at": "2015-02-05T16:56:51.252+08:00",
        "country_code": "TW",
        "email": "test@commandp.com"
      },
      "created_at": "2015-02-05 16:56:51 +0800",
      "links": [{
        "role": "works",
        "url": "http://commandp.dev/api/my/works?locale=en",
        "accept": "application/commandp.v2"
      }],
      "order_items": [{
        "quantity": 1,
        "price": 29.95,
        "work_uuid": "7f2ebe58-76e3-11e4-a48f-0af8b85e109a",
        "work_name": "Seed Me",
        "model_name": "iPhone 6 Cases",
        "model_key": "iphone_6_cases",
        "order_image": "http://commandp.dev/order_image20141128-49145-19qjmre.jpg?v=1423126592",
        "links": [{
          "role": "orders",
          "url": "http://commandp.dev/api/my/orders?locale=en",
          "accept": "application/commandp.v2"
        }, {
          "role": "order",
          "url": "http://commandp.dev/api/my/orders/2847?locale=en",
          "accept": "application/commandp.v2"
        }]
      }],
      "message": "发票抬头"
    }
  }
=end
class Api::V2::My::OrdersController < ApiV2Controller
  before_action :authenticate_required!
  before_action :find_order, only: [:show, :pay]
  before_action :validate_build_order, only: :update
  before_action :find_or_initialize_order, only: :update

=begin
@api {get} /api/my/orders Get User order list
@apiUse NeedAuth
@apiUse OrderResponse
@apiGroup My/Orders
@apiName GetMyOrders
@apiVersion 2.0.0
@apiSuccessExample {json} Success-Response:
  {
    "orders": [{
      "uuid": "a520298a-aded-11e4-ae64-3c15c2d24fd8",
      "status": "Paid",
      "order_no": "1526284839TW",
      "created_at": "2015-02-06T18:48:12.474+08:00"
    }, {
      "uuid": "9f68e2d8-5eac-11e4-bdbc-0af8b85e109a",
      "status": "Canceled",
      "order_no": "14AS120863TW",
      "created_at": "2014-10-28T22:13:43.264+08:00"
    }]
  }
=end
  def index
    @orders = current_user.orders.viewable.order('created_at DESC')
    render 'api/v3/orders/index'
    fresh_when(etag: @orders)
  end

=begin
@api {get} /api/my/orders/:uuid Show user order
@apiUse NeedAuth
@apiGroup My/Orders
@apiName ShowMyOrder
@apiVersion 2.0.0
=end
  def show
    render 'api/v3/orders/show'
    fresh_when(etag: @order, last_modified: @order.updated_at)
  end

=begin
@api {patch} /api/my/order/:order_uuid/pay User Order Pay
@apiUse NeedAuth
@apiGroup My/Orders
@apiName PayMyOrder
@apiVersion 2.0.0
@apiSuccessExample {json} Success-Response:
  {
    "order" => {
      "uuid" => "07ac78b8-a2b0-11e4-8603-3c15c2d24fd8",
      "status" => "paid",
      "payment" => "cash_on_delivery",
      "order_no" => "151N000165US",
      "payment_info" => {
        "payment_method" => "cash_on_delivery"
      },"links" => [{
          "role" => "orders",
          "url" => "http://www.example.com/api/my/orders?locale=en",
          "accept" => "application/commandp.v2"
        }, {
          "role" => "order",
          "url" => "http://www.example.com/api/my/orders/1?locale=en",
          "accept" => "application/commandp.v2"
      }]
    }
  }
=end
  def pay
    @order.with_lock do
      if @order.pending?
        @order.attributes = api_permitted_params.order_pay
        log_with_current_user @order
        if @order.payment_object.pay
          render 'api/v3/orders/show'
        else
          fail OrderPayError, @order.errors.full_messages.join(',')
        end
      else
        render 'api/v3/orders/show'
      end
    end
  end

=begin
@api {put} /api/my/orders/:uuid Update User Order
@apiUse NeedAuth
@apiUse OrderResponse
@apiGroup My/Orders
@apiName PutMyOrders
@apiVersion 2.0.0
@apiParamExample {json} Request-Example
  PUT /api/my/orders/1b9a54fc-5a59-11e4-865e-3c15c2d24fd8
  {
    currency: 'USD',
    coupon: '',
    auth_token: "auth_token",
    billing_info: {
      name: "Firstname Lastname",
      phone: "1234123124",
      address: "Address",
      state: "State",
      zip_code: "Zip Code",
      country: "Taiwan",
      country_code: "TW",
      shipping_way: "Shipping way",
      email: "a_user@gmail.com"
    },
    shipping_info: {
      name: "Firstname Lastname",
      phone: "1234123124",
      address: "Address",
      state: "State",
      zip_code: "Zip Code",
      country: "Taiwan",
      country_code: "TW",
      shipping_way: "Shipping way",
      email: "a_user@gmail.com"
    },
    order_items: [{
      work_uuid: 1bf03ce6-5a59-11e4-865e-3c15c2d24fd8,
      quantity: 2
    }],
    "message": "发票抬头"
  }
=end
  def update
    @order.with_lock do
      @order.build_order(order_params)
      if @order.save
        render 'api/v3/orders/show'
      else
        fail OrderError, @order.errors.full_messages.join(',')
      end
    end
  end

=begin
@api {post} /api/my/orders/price Get cart price
@apiUse NeedAuth
@apiGroup My/Orders
@apiName PostGetOrderPrice
@apiVersion 2.0.0
@apiParam {String} currency 貨幣
@apiParam {String} coupon Coupon Code
@apiParam {String="standard","express"} shipping_way 運送方式
@apiParam {String="create","shop"} order_items_type 若是商城內的商品 type: shop, 開始做為 type: create
@apiParam {String} [order_items_work_uuid] type 是 shop 才傳入 work_uuid
@apiParam {String} [order_items_product_model_key] type 是 create 才傳入 product_model_key
@apiParamExample {json} Request-Example
  POST /api/my/orders/price
  {
    auth_token: "auth_token",
    currency: 'USD',
    coupon: '',
    shipping_info: {
      shipping_way: "Shipping way",
    },
    order_items: [{
      type: "shop"
      work_uuid: "1bf03ce6-5a59-11e4-865e-3c15c2d24fd8",
      quantity: 2
    },{
      type: "create"
      product_model_key, "ProductModel Key"
      quantity: 2
    }]
  }

@apiSuccessExample {json} Success-Response:
  HTTP/1.1 200 OK
  {
    "order": {
      "currency": "USD",
      "coupon": "9C7158",
      "price": {
        "subtotal": "499.5",
        "discount": "5.0",
        "shipping_fee": "0.0",
        "price": 494.5
      },
      "display_price": {
        "subtotal": "$499.50",
        "discount": "$5.00",
        "shipping_fee": "$0.00",
        "price": "$494.50"
      }
    },
    "meta": {
      "items_count": 5
    }
  }

@apiSuccessExample {json} Success-Response(with cureency:TWD ):
  HTTP/1.1 200 OK
  {
    "order": {
        "currency": "TWD",
        "coupon": "A19260",
        "price": {
            "subtotal": "14995.0",
            "discount": "150.0",
            "shipping_fee": "0.0",
            "price": 14845.0
        },
        "display_price": {
            "subtotal": "NT$14,995",
            "discount": "NT$150",
            "shipping_fee": "NT$0",
            "price": "NT$14,845"
        }
    },
    "meta": {
        "items_count": 5
    }
}

@apiSuccessExample {json} 回傳(coupon_code error):
  HTTP/1.1 400 OK
  {
    "error" => "Cannot use the coupon code.", "code" => "InvalidCouponError"
  }
=end
  def price
    order = Order.new
    order.build_tmp_order(cart_params)
    render json: order, serializer: Api::V2::OrderPriceSerializer, root: 'order',
           meta: { items_count: order.print_items_count }
  end

  private

  def cart_params
    params.permit([:currency, :shipping_way, shipping_info: [:shipping_way]]).merge!(coupon_code: check_coupon_code,
                                                                                     items: build_cart_order_itmes)
  end

  def check_coupon_code
    params[:coupon] if params[:coupon].present? && Coupon.find_valid(params[:coupon], current_user)
  end

  def build_cart_order_itmes
    fail ApplicationError, 'order_items can\'t be blank' unless params[:order_items].present?
    params[:order_items].map do |order_item|
      case order_item[:type]
      when 'create'
        { product_model_key: order_item[:product_model_key], quantity: order_item[:quantity] }
      when 'shop'
        { work_uuid: order_item[:work_uuid], quantity: order_item[:quantity] }
      end
    end
  end

  def order_params
    api_permitted_params.order.merge(platform: os_type,
                                     ip: remote_ip,
                                     user_agent: user_agent,
                                     locale: locale)
  end

  def locale
    if request.headers['Accept-Language']
      accept_locale = request.headers['Accept-Language'].split(',').first
      locale = accept_locale if I18n.available_locales.include?(accept_locale.to_sym)
    end
    locale || 'en'
  end

  def validate_build_order
    if order_params[:order_items].blank?
      return fail OrderItemsEmptyError
    else
      order_params[:order_items].each do |order_item|
        work = Work.find_by(uuid: order_item['work_uuid']) || StandardizedWork.published.find_by(uuid: order_item['work_uuid'])
        fail WorkNotFoundError unless work.present?
        if !work.is_a? StandardizedWork
          fail WorkNotFinishError unless work.finished?
        end
      end
    end
  end

  def find_order
    @order = current_user.orders.viewable.find_by!(uuid: params[:uuid] || params[:order_uuid])
  end

  def find_or_initialize_order
    @order = current_user.orders.viewable.where(uuid: params[:uuid]).first_or_initialize
    log_with_current_user @order
  end
end
