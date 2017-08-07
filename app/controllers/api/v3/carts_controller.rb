=begin
 @apiDefine CartShowResponse
 @apiSuccessExample {json} Response-Example:
 {
  "cart": {
    "price": "NT$1,798",
    "subtotal": "NT$1,798",
    "shipping_fee": "NT$0",
    "discount": "NT$0",
    "coupon_code": null,
    "order_item_quantity_total": 2,
    "payment": "stripe",
    "payment_path": "/zh-TW/payment/stripe/begin",
    "shipping_info_shipping_way": "standard",
    "order_items": [
      {
        "item": {
          "id": 3583,
          "gid": "Z2lkOi8vY29tbWFuZC1wL1dvcmsvMzU4Mw",
          "uuid": "78108a66-cc79-11e4-9ca2-ac87a30f9d14",
          "name": "Created By Api V3  yes",
          "user_avatar": {
            "avatar": {
              "url": "http://commandp.dev/uploads/user/avatar/1/03b1b561.jpg?v=1454129975",
              "s35": {
                "url": "http://commandp.dev/uploads/user/avatar/1/s35_03b1b561.jpg?v=1454129975"
              },
              "s114": {
                "url": "http://commandp.dev/uploads/user/avatar/1/s114_03b1b561.jpg?v=1454129975"
              },
              "s154": {
                "url": "http://commandp.dev/uploads/user/avatar/1/s154_03b1b561.jpg?v=1454129975"
              }
            }
          },
          "user_id": 1,
          "order_image": {
            "thumb": null,
            "share": null,
            "sample": null,
            "normal": null
          },
          "gallery_images": [],
          "original_prices": {
            "TWD": 899,
            "USD": 29.95,
            "JPY": 3480,
            "HKD": 229
          },
          "prices": {
            "TWD": 899,
            "USD": 29.95,
            "JPY": 3480,
            "HKD": 229
          },
          "user_display_name": "",
          "wishlist_included": false,
          "slug": "my-design-a2bbae40-5a50-479c-bd87-296503c15fe1",
          "is_public": false,
          "user_avatars": {
            "s35": "http://commandp.dev/uploads/user/avatar/1/s35_03b1b56105cd9e39bd02a91890f29f5b.jpg?v=1454129975",
            "s154": "http://commandp.dev/uploads/user/avatar/1/s154_03b1b56105cd9e39bd02a91890f29f5b.jpg?v=1454129975"
          },
          "spec": {
            "id": 8,
            "name": "iPhone 6 Plus 手機殼",
            "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n- 超輕 12.5 g\r\n- 熱轉印特殊防刮抗磨塑料",
            "width": 99,
            "height": 178,
            "dpi": 300,
            "background_image": null,
            "overlay_image": null,
            "padding_top": "0.0",
            "padding_right": "0.0",
            "padding_bottom": "0.0",
            "padding_left": "0.0",
            "__deprecated": "WorkSpec is not longer available"
          },
          "model": {
            "id": 8,
            "key": "iphone_6plus_cases",
            "name": "iPhone 6 Plus 手機殼",
            "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n- 超輕 12.5 g\r\n- 熱轉印特殊防刮抗磨塑料",
            "prices": {
              "TWD": 899,
              "USD": 29.95,
              "JPY": 3480,
              "HKD": 229
            },
            "customized_special_prices": null,
            "design_platform": {
              "ios": true,
              "android": true,
              "website": true
            },
            "customize_platform": {
              "ios": false,
              "android": false,
              "website": true
            },
            "placeholder_image": null,
            "width": 99,
            "height": 178,
            "dpi": 300,
            "background_image": null,
            "overlay_image": null,
            "padding_top": "0.0",
            "padding_right": "0.0",
            "padding_bottom": "0.0",
            "padding_left": "0.0"
          },
          "product": {
            "id": 8,
            "key": "iphone_6plus_cases",
            "name": "iPhone 6 Plus 手機殼",
            "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n- 超輕 12.5 g\r\n- 熱轉印特殊防刮抗磨塑料",
            "prices": {
              "TWD": 899,
              "USD": 29.95,
              "JPY": 3480,
              "HKD": 229
            },
            "customized_special_prices": null,
            "design_platform": {
              "ios": true,
              "android": true,
              "website": true
            },
            "customize_platform": {
              "ios": false,
              "android": false,
              "website": true
            },
            "placeholder_image": null,
            "width": 99,
            "height": 178,
            "dpi": 300,
            "background_image": null,
            "overlay_image": null,
            "padding_top": "0.0",
            "padding_right": "0.0",
            "padding_bottom": "0.0",
            "padding_left": "0.0"
          },
          "category": {
            "id": 5,
            "key": "case",
            "name": "手機殼"
          },
          "featured": false,
          "tags": [
            {
              "id": 3,
              "name": "tag_1",
              "text": "标签1"
            },
            {
              "id": 6,
              "name": "tag_2",
              "text": "标签2"
            }
          ]
        },
        "quantity": 2
      }
    ],
    "currency": "TWD"
  },
  "meta": {
    "items_count": 1,
    "current_currency_code": "TWD"
  }
}
=end

class Api::V3::CartsController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :check_user

  before_action :find_cart
=begin
@api {get} /api/cart Get Cart items
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Carts
@apiName GetCart
@apiUse CartShowResponse
=end
  def show
    # TODO: 這裡應該改成只需要傳 @cart?
    @current_currency_code = current_currency_code
    # 用户使用coupon后再修改cart，可能会造成coupon不能使用
    # 目前先抓CannotUseCouponError异常
    order = begin
      @cart.build_tmp_order
    rescue CannotUseCouponError
      @cart.clear_coupon_code
      @cart.build_tmp_order
    end

    @order = Api::V3::OrderDecorator.new(order)
  end

=begin
@api {delete} /api/cart Cleanup cart
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Carts
@apiName CleanupCart
@apiSuccessExample {json} Response-Example:
 {
    "status": "success"
    "meta": {
      items_count: 0
    }
  }
=end
  def destroy
    @cart.clean
    @cart.save
    render json: {
      status: :success,
      meta: { items_count: @cart.items.count }
    }
  end

=begin
@api {put} /api/cart Update cart order info
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Carts
@apiName UpdateCart
@apiParam {String} [coupon_code] coupon_code
@apiParam {String='true'} [clear_coupon_code] flag to clear the coupon_code
@apiParam {Object} order order info structure
@apiParam {String} [order.currency] order currency, default: current_currency_code decided by current_country_code
@apiParam {String="redeem", "paypal", "neweb/atm",
, "neweb/alipay", "neweb_mpp", "stripe", "pingpp_alipay", "pingpp_alipay_wap",
"pingpp_wx", "pingpp_upacp", "pingpp_bfb", "pingpp_upacp_wap", "pingpp_alipay_qr",
"pingpp_alipay_pc_direct",
"camera360", "pingpp_upacp_pc", "pingpp_wx_pub_qr", "redeem"} [order.payment="paypal"] order payment, default: paypal
@apiParam {String} [order.message] message
@apiParam {Object} order.billing_info billing's info structure
@apiParam {String} order.billing_info.email billing_info's email
@apiParam {String} order.billing_info.country billing_info country
@apiParam {String} order.billing_info.country_code billing_info country_code
@apiParam {String} [order.billing_info.name] billing_info name
@apiParam {String} order.billing_info.address billing_info address
@apiParam {String} order.billing_info.zip_code billing_info zip_code
@apiParam {String} order.billing_info.phone billing_info phone
@apiParam {String="standard", "express"} [order.billing_info.shipping_way="standard"] shipping_way
@apiParam {String} order.billing_info.city billing_info city
@apiParam {String} order.billing_info.state billing_info state
@apiParam {Object} order.shipping_info shipping_info's structure
@apiParam {String} order.shipping_info.email shipping_info email
@apiParam {String} order.shipping_info.country shipping_info country
@apiParam {String} order.shipping_info.country_code shipping_info country_code
@apiParam {String} [order.shipping_info.name] shipping_info name
@apiParam {String} order.shipping_info.address shipping_info address
@apiParam {String} order.shipping_info.zip_code shipping_info zip_code
@apiParam {String} order.shipping_info.phone shipping_info phone
@apiParam {String="standard", "express"} [order.shipping_info.shipping_way="standard"] shipping_way
@apiParam {String} order.shipping_info.city shipping_info city
@apiParam {String} order.shipping_info.state shipping_info state
@apiParam {Integer} order.shipping_info.province_id shipping_info province_id
@apiUse CartShowResponse
=end
  def update
    update_coupon
    @cart.update_check_out(order_params) if params[:order]
    @cart.save
    # 更新了coupon规则后，存储在cart的coupon会报错，需先清除coupon,重新输入
    begin
      @order = @cart.build_tmp_order
    rescue CannotUseCouponError
      @cart.clear_coupon_code
      @order = @cart.build_tmp_order
    end

    @order = Api::V3::OrderDecorator.new(@order)
    @current_currency_code = current_currency_code
    render :show
  end

=begin
@api {post} /api/cart/check_out Checkout cart to build a order
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Carts
@apiName CheckoutCart
@apiSuccessExample {json} Response-Example:
  {
  "order": {
    "uuid": "940a5b8c-c991-11e5-adb6-ac87a30f9d14",
    "price": 1798,
    "currency": "TWD",
    "status": "pending",
    "status_i18n": "未付款",
    "payment": "paypal",
    "ship_code": null,
    "payment_info": {
      "method": "paypal"
    },
    "coupon": "",
    "order_price": {
      "subtotal": "1798.0",
      "discount": "0.0",
      "shipping_fee": "0.0",
      "price": 1798
    },
    "order_no": "1602025300034TW",
    "created_at": "2016-02-02T17:44:39.606+08:00",
    "message": null,
    "activities": [
      {
        "key": "create",
        "created_at": "2016-02-02T17:44:39.703+08:00"
      }
    ],
    "billing_info": {
      "id": 236,
      "address": "Taipei Jedi Road",
      "city": "Taipei",
      "name": "Jedi Yoda",
      "phone": "023312233",
      "state": "JEDI",
      "zip_code": "123",
      "province_id": 1,
      "country": "Taiwan",
      "created_at": "2016-02-02T17:44:39.634+08:00",
      "updated_at": "2016-02-02T17:44:39.634+08:00",
      "country_code": "TW",
      "shipping_way": "standard",
      "email": "yaya@commandp.com",
      "address_name": null
    },
    "shipping_info": {
      "id": 237,
      "address": "Taipei Jedi Road",
      "city": "Taipei",
      "name": "Jedi",
      "phone": "0223134422",
      "state": "Jedi",
      "province_id": 1,
      "zip_code": "123",
      "country": "Taiwan",
      "created_at": "2016-02-02T17:44:39.644+08:00",
      "updated_at": "2016-02-02T17:44:39.644+08:00",
      "country_code": "TW",
      "shipping_way": "standard",
      "email": "yaya@commandp.com",
      "address_name": null
    },
    "order_items": [
      {
        "quantity": 2,
        "price": 899,
        "work_uuid": "78108a66-cc79-11e4-9ca2-ac87a30f9d14",
        "work_name": "Created By Api V3  yes",
        "model_name": "iPhone 6 Plus 手機殼",
        "model_key": "iphone_6plus_cases",
        "product_name": "iPhone 6 Plus 手機殼",
        "product_key": "iphone_6plus_cases",
        "order_image": null,
        "name": "Created By Api V3  yes",
        "links": {
          "edit": "/zh-TW/admin/works/my-design-a2bbae40-5a50-479c-bd87-296503c15fe1/edit",
          "create_note": "/zh-TW/admin/order_items/128/notes"
        },
        "images": {
          "order_image": {
            "thumb": null,
            "origin": null
          },
          "cover_image": {
            "thumb": "http://commandp.dev/media/BAhbCUdd.png",
            "origin": "http://commandp.dev/uploads/work/cover_image/3583/uploaded.png?v=1454402487"
          },
          "print_image": {
            "thumb": null,
            "origin": null
          }
        },
        "notes": []
      }
    ]
  },
  "meta": {
    "items_count": 1
  }
}
=end
  def check_out
    @order = @cart.build_order
    fail OrderError, @order.errors.full_messages.join(',') unless @order.save
    @order.update checked_out_at: Time.zone.now
    @cart.clean
    render 'api/v3/orders/show'
  end

  protected

  def update_coupon
    if params[:clear_coupon_code].to_b
      clear_coupon
    else
      verify_coupon
    end
  end

  def verify_coupon
    return unless params[:coupon_code]
    coupon_code = params[:coupon_code].upcase
    if @cart.valid_coupon_code?(coupon_code, current_user)
      @cart.apply_coupon_code(coupon_code)
    else
      fail ParametersInvalidError, caused_by: :coupon_code
    end
  end

  def clear_coupon
    @cart.clear_coupon_code
  end

  def find_cart
    args = { controller: self, user_id: current_user.id }
    args[:store_id] = params[:store_id] if params[:store_id].present?
    @cart = CartSession.new(args)
  end

  def order_params
    params.require(:order).permit(:payment,
                                  :currency,
                                  :message,
                                  order_info: api_permitted_params.order_info_attr,
                                  billing_info: api_permitted_params.billing_profile_attrs,
                                  shipping_info: api_permitted_params.billing_profile_attrs)
  end
end
