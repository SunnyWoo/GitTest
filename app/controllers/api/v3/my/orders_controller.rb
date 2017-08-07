=begin
@apiDefine OrderResponse
@apiSuccessExample {json} Response-Example:
  {
  "order": {
    "uuid": "b82f2464-c641-11e5-bb2e-ac87a30f9d14",
    "price": 2998,
    "currency": "TWD",
    "status": "pending",
    "status_i18n": "未付款",
    "payment": "paypal",
    "ship_code": null,
    "logistics_info" : [
      {ship_code: '123', logistics_supplier_name: '圆通' },
      {...}
     ],
    "payment_info": {
      "method": "paypal"
    },
    "coupon": "",
    "order_price": {
      "subtotal": "2998.0",
      "discount": "0.0",
      "shipping_fee": "65.0",
      "price": 2998,
      "expired_at": "2016-01-30T12:35:27.014+08:00",
      "identifier": "f9e44c4af9377cf992a92759b375b4c0",
      "adjustments": [{id: 1, reason: '符合活動資格', created_at: '2016-01-29T12:35:27.014+08:00'}],
      "valid": true
    },
    "display_price": {
      "subtotal": "NT$2,998",
      "discount": "NT$0",
      "shipping_fee": "NT$65",
      "price": "NT$2,998"
    },
    "order_no": "1601295900017TW",
    "created_at": "2016-01-29T12:35:27.014+08:00",
    "check_paid_at": "2016-03-10T18:55:45.863+08:00",
    "message": null,
    "activities": [
      {
        "key": "create",
        "created_at": "2016-01-29T12:35:27.146+08:00"
      }
    ],
    "billing_info": {
      "id": 226,
      "address": "Taipei city hall",
      "city": "Taipei",
      "name": "that's noy my name",
      "phone": "0228825252,
      "state": "Taipei",
      "zip_code": "123",
      "country": "台灣",
      "created_at": "2016-01-30T11:47:57.254+08:00",
      "updated_at": "2016-01-30T11:47:57.254+08:00",
      "country_code": "TW",
      "dist_code": "103",
      "shipping_way": "standard",
      "email": "test@commandp.com",
      "address_name": "Tapei City Hall Station"
    },
    "shipping_info": {
      "id": 227,
      "address": "Taipei city hall",
      "city": "Taipei",
      "name": "that's noy my name",
      "phone": "0228825252,
      "state": "Taipei",
      "zip_code": "123",
      "country": "台灣",
      "created_at": "2016-01-30T11:47:57.254+08:00",
      "updated_at": "2016-01-30T11:47:57.254+08:00",
      "country_code": "TW",
      "dist_code": "103",
      "shipping_way": "standard",
      "email": "test@commandp.com",
      "address_name": "Tapei City Hall Station"
    },
    "order_items": [
      {
        "quantity": 2,
        "price": 1499,
        "work_uuid": "70d90d94-ab50-11e4-99ac-ac87a30f9d14",
        "work_name": "My Design",
        "is_public": true,
        "user_display_name": "囧哥",
        "model_name": "iPad mini 保護殼",
        "model_key": "ipad_mini_cases",
        "product_name": "iPad mini 保護殼",
        "product_key": "ipad_mini_cases",
        "order_image": "http://commandp.dev/media/=--a70ae7b657dbafaf43329c50342584611277eaad.jpg",
        "name": "My Design",
        "links": {
          "edit": "/zh-TW/admin/works/my-design-58ec9c28-6b2d-43f7-b4cc-d451b3a28c20/edit",
          "create_note": "/zh-TW/admin/order_items/124/notes"
        },
        "images": {
          "order_image": {
            "thumb": "http://commandp.dev/media/+0FQ=--a70ae7b657dbafaf43329c50342584611277eaad.jpg",
            "origin": "http://commandp.dev/uploads/preview/image/2/order_image20150203-t076nz.jpg?v=1422933576"
          },
          "cover_image": {
            "thumb": "http://commandp.dev/media/BAhbCUkiHmdpZDovL2NvbW1hbmQtcC9Xb3JrLzM0O.png",
            "origin": "http://commandp.dev/uploads/work/cover_image/3490/uploaded_cover_image.png?v=1446195701"
          },
          "print_image": {
            "thumb": "http://commandp.dev/media/BAhbCUkiHmdpZDovL2NvbW1hbmQtcC9Xb3JrLzM0O.png",
            "origin": "http://commandp.dev/uploads/work/print_image/3490/p-4638-14i16ue.png?v=1446195701"
          }
        },
        "notes": []
      }
    ]
  }
}
=end
class Api::V3::My::OrdersController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :check_user
  before_action :find_order, only: %w(show pay destroy cancel)
  before_action :validate_order_writable!, only: [:pay, :update]
  before_action :validate_build_order, only: :update
  before_action :find_or_initialize_order, only: :update
  # before_action :check_shipping_fee_available!, only: :pay

=begin
@api {get} /api/my/orders User Order list
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup My/Orders
@apiName UserOrderList
@apiParam {String} scope order aasm_state
@apiParamExample {json} Response-Example:
 {
   "orders": [{
     "uuid": "a520298a-aded-11e4-ae64-3c15c2d24fd8",
     "status": "Paid",
     "status_i18n": "已付款",
     "order_no": "1526284839TW",
     "created_at": "2015-02-06T18:48:12.474+08:00"
   }, {
     "uuid": "9f68e2d8-5eac-11e4-bdbc-0af8b85e109a",
     "status": "Canceled",
     "status_i18n": "取消",
     "order_no": "14AS120863TW",
     "created_at": "2014-10-28T22:13:43.264+08:00"
   }],
   "meta": {
      "orders_count": 2
   }
 }
=end
  def index
    @orders = Api::V3::MyOrdersPresenter.new(current_user, params[:scope])
    fresh_when(etag: @orders.etag)
  end

=begin
@api {get} /api/my/orders/:uuid Show user order
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup My/Orders
@apiName ShowUserOrder
@apiParam {String} uuid order uuid
@apiUse OrderResponse
=end
  def show
    @order = Api::V3::OrderDecorator.new(@order)
    fresh_when(etag: @order, last_modified: @order.updated_at)
  end

=begin
@api {patch} /api/my/orders/:order_uuid/pay User Order Pay
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup My/Orders
@apiName UserOrderPay
@apiParam {String} uuid order uuid
@apiParam {String} payment_id payment_id
@apiParam {String="redeem", "paypal", "neweb/atm",
, "neweb/alipay", "neweb_mpp", "stripe", "pingpp_alipay", "pingpp_alipay_wap",
"pingpp_wx", "pingpp_upacp", "pingpp_bfb", "pingpp_upacp_wap", "pingpp_alipay_qr", "pingpp_alipay_pc_direct",
"camera360", "pingpp_upacp_pc", "pingpp_wx_pub_qr", "redeem"} payment_method payment method
@apiParamExample {json} Response-Example:
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
@apiErrorExample {json} 回傳(Shipping Fee Unavailable):
 HTTP/1.1 400 Bad Request
 {
   "error" => "Cannot calculate shipping without completed address.", "code" => "Pricing::ShippingFeeUnavailableError"
 }
=end

  # TODO: fix paypal raise error message by rich
  def pay
    @order.with_lock do
      if @order.pending?
        @order.attributes = api_permitted_params.order_pay
        @order.save
        check_shipping_fee_available!
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
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup My/Orders
@apiName UpdateUserOrder
@apiVersion 2.0.0
@apiParam {String} uuid order uuid
@apiParam {String} currency order currency
@apiParam {String} [coupcon] coupon code that order used
@apiParam {Object[]} order_items order_items' structure
@apiParam {String} order_items.work_uuid the work uuid that order item come from
@apiParam {Integer} order_items.quantity the order item's quantity
@apiParam {Object} billing_info billing's info structure
@apiParam {String} billing_info.email billing_info's email
@apiParam {String} billing_info.country billing_info country
@apiParam {String} billing_info.country_code billing_info country_code
@apiParam {String} [billing_info.name] billing_info name
@apiParam {String} billing_info.address billing_info address
@apiParam {String} billing_info.zip_code billing_info zip_code
@apiParam {String} billing_info.phone billing_info phone
@apiParam {String="standard", "express"} billing_info.shipping_way billing_info shipping_way
@apiParam {String} billing_info.city billing_info city
@apiParam {String} billing_info.state billing_info state
@apiParam {Object} shipping_info shipping_info's structure
@apiParam {String} shipping_info.email shipping_info email
@apiParam {String} shipping_info.country shipping_info country
@apiParam {String} shipping_info.country_code shipping_info country_code
@apiParam {String} shipping_info.dist shipping_info the name of district in address
@apiParam {String} shipping_info.dist_code shipping_info the code of district in address
@apiParam {String} shipping_info.name shipping_info name
@apiParam {String} shipping_info.address shipping_info address
@apiParam {String} shipping_info.zip_code shipping_info zip_code
@apiParam {String} shipping_info.phone shipping_info phone
@apiParam {String="standard", "express"} shipping_info.shipping_way shipping_info shipping_way
@apiParam {String} shipping_info.city shipping_info city
@apiParam {String} shipping_info.state shipping_info state
@apiParam {String} shipping_info.province shipping_info province
@apiParamExample {json} Request-Example
  PUT /api/my/orders/1b9a54fc-5a59-11e4-865e-3c15c2d24fd8
  {
    currency: 'USD',
    coupon: '',
    billing_info: {
      name: "Firstname Lastname",
      phone: "1234123124",
      address: "Address",
      state: "State",
      zip_code: "Zip Code",
      country: "Taiwan",
      country_code: "TW",
      dist_code: "103",
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
      dist_code: "103",
      shipping_way: "Shipping way",
      email: "a_user@gmail.com"
    },
    order_items: [{
      work_uuid: 1bf03ce6-5a59-11e4-865e-3c15c2d24fd8,
      quantity: 2
    }],
    pricing_identifier: 'xxxxxx'
    message: "发票抬头"
  }
@apiUse OrderResponse
=end
  def update
    if repay_with_pricing_identifier?

      @order.check_pricing_identifier!(pricing_identifier)
      @order.update_attributes(repay_params)
      check_shipping_fee_available!
      @order.locked!
    else
      @order.with_lock do
        @order.build_order(order_params)
        unless @order.save
          fail OrderError, @order.errors.full_messages.join(',')
        end
      end
    end

    @order = Api::V3::OrderDecorator.new(@order)
    render :show
  end

=begin
@api {patch} /api/my/orders/:uuid Soft Destroy User Shipping Order
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup My/Orders
@apiName DestroyUserOrder
@apiVersion 2.0.0
@apiParamExample {json} Request-Example
  patch /api/my/orders/1b9a54fc-5a59-11e4-865e-3c15c2d24fd8
  {
    currency: 'USD',
    coupon: '',
    billing_info: {
      name: "Firstname Lastname",
      phone: "1234123124",
      address: "Address",
      state: "State",
      zip_code: "Zip Code",
      country: "Taiwan",
      country_code: "TW",
      dist_code: "103",
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
      dist_code: "103",
      shipping_way: "Shipping way",
      email: "a_user@gmail.com"
    },
    order_items: [{
      work_uuid: 1bf03ce6-5a59-11e4-865e-3c15c2d24fd8,
      quantity: 2
    }],
    "message": "发票抬头"
  }
@apiUse OrderResponse
=end

  def destroy
    if @order.shipping?
      @order.update viewable: false
      log_with_current_user(@order)
      @order.create_activity(:destroy)
      render :show
    else
      fail DestroyOrderStateError
    end
  end

=begin
@api {post} /api/my/orders/price Get cart price
@apiUse ApiV3
@apiGroup My/Orders
@apiName PostGetOrderPrice
@apiVersion 3.0.0
@apiParam {String} currency 貨幣
@apiParam {String} coupon Coupon Code
@apiParam {String="standard"} shipping_way 運送方式
@apiParam {String="create","shop"} order_items_type 若是商城內的商品 type: shop, 開始做為 type: create
@apiParam {String} [order_items_work_uuid] type 是 shop 才傳入 work_uuid
@apiParam {String} [order_items_product_model_key] type 是 create 才傳入 product_model_key
@apiParamExample {json} Request-Example
  POST /api/my/orders/price
  {
    access_token: "access_token",
    currency: 'USD',
    coupon: '',
    shipping_info: {
      shipping_way: "Shipping way",
      country_code: 'TW',
      country: 'Taiwan',
      city: '台北市'
      dist: '松山區'
      dist_code: '106',
      address: '南京東路五段87號',
      zip_code: '10698'
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
        "price": 494.5,
        "expired_at": null,
        "identifier": "6c48b970863a5f37d578c7f0d6d00437",
        "valid": true
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

@apiSuccessExample {json} Success-Response(with currency:TWD ):
  HTTP/1.1 200 OK
  {
    "order": {
        "currency": "TWD",
        "coupon": "A19260",
        "price": {
            "subtotal": "14995.0",
            "discount": "150.0",
            "shipping_fee": nil,
            "price": 14845.0,
            "expired_at": null,
            "identifier": "6c48b970863a5f37d578c7f0d6d00437",
            "valid": false,
            "error": "地址未填寫無法計算運費"
        },
        "display_price": {
            "subtotal": "NT$14,995",
            "discount": "NT$150",
            "shipping_fee": nil,
            "price": "NT$14,845"
        }
    },
    "meta": {
        "items_count": 5
    }
}

@apiSuccessExample {json} Success-Response(Shipping Fee is Not Available):
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
            "expired_at": null,
            "identifier": "6c48b970863a5f37d578c7f0d6d00437",
            "valid": false,
            "error": "地址未完整填寫無法計算運費"
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

@apiErrorExample {json} 回傳(coupon_code error):
  HTTP/1.1 400 Bad Request
  {
    "error" => "Cannot use the coupon code.", "code" => "InvalidCouponError"
  }
=end
  def price
    order = Order.build_for_api_pricing!(current_user, cart_params)
    @order = Api::V3::OrderDecorator.new(order)
  end

=begin
@api {put} /api/my/orders/:uuid/cancel Cancel order
@apiDescription Only order status (pending, waiting_for_payment), can cancel order
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup My/Orders
@apiName CancelUserOrder
@apiParam {String} uuid order uuid
@apiUse OrderResponse
@apiErrorExample {json} RecordNotFoundError: 找不到訂單
  HTTP/1.1 404 Not Found
  {
    "error": "系統繁忙中，請重新嘗試或聯繫客服",
    "code": "RecordNotFoundError"
  }
@apiErrorExample {json} OrderError: 取消訂單失敗
  HTTP/1.1 400 Bad Request
  {
    "error": "訂單無法取消，請刷新頁面並重新嘗試",
    "code": "OrderError"
  }
=end
  def cancel
    @order.cancel!
    fail OrderError, @order.errors.full_messages.join(',') unless @order.valid?
    render :show
  rescue AASM::InvalidTransition
    fail OrderError, I18n.t('errors.order_cancel_invalid')
  end

  private

  def cart_params
    params.permit(
      :currency, :shipping_way, :coupon,
      order_items: [:type, :product_model_key, :work_uuid, :quantity],
      shipping_info: api_permitted_params.billing_profile_attrs
    )
  end

  def order_params
    api_permitted_params.order.merge(platform: os_type,
                                     ip: remote_ip,
                                     user_agent: user_agent,
                                     locale: locale,
                                     app_id: current_application.id)
  end

  def repay_params
    params.permit(:payment, :payment_method)
  end

  def locale
    if request.headers['Accept-Language']
      accept_locale = request.headers['Accept-Language'].split(',').first
      locale = accept_locale if I18n.available_locales.include?(accept_locale.to_sym)
    end
    locale || 'en'
  end

  def validate_build_order
    return if repay_with_pricing_identifier?

    if order_params[:order_items].blank?
      fail OrderItemsEmptyError
    else
      order_params[:order_items].each do |order_item|
        work = Work.find_by(uuid: order_item['work_uuid']) ||
               StandardizedWork.published.find_by(uuid: order_item['work_uuid'])
        fail WorkNotFoundError unless work.present?
        fail WorkNotFinishError unless (work.is_a?(StandardizedWork) || work.finished?)
      end
    end
  end

  def find_order
    @order = current_user.orders.viewable.find_by(order_no: params[:uuid]) ||
             current_user.orders.viewable.find_by!(uuid: params[:uuid] || params[:order_uuid])
  rescue ActiveRecord::RecordNotFound
    fail RecordNotFoundError, I18n.t('errors.order_record_not_found')
  end

  def find_or_initialize_order
    @order = current_user.orders.viewable.where(uuid: params[:uuid]).first_or_initialize
    log_with_current_user @order
  end

  def validate_order_writable!
    fail OrderExpireDayAutoCancelError if @order.try(:canceled?)
  end

  def check_shipping_fee_available!
    fail Pricing::ShippingFeeUnavailableError if @order.shipping_fee.nil?
  end

  def repay_with_pricing_identifier?
    pricing_identifier.present?
  end

  def pricing_identifier
    @pricing_identifier ||= params[:pricing_identifier]
  end
end
