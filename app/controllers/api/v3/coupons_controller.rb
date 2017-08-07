class Api::V3::CouponsController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {get} /api/validate validate coupon code
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Coupons
@apiName ValidateCoupon
@apiParam {code} coupon code
@apiSuccessExample {json} Response-Example:
{
  "coupon": {
    "id": 110,
    "quantity": 1,
    "title": "GOGOGOGGO",
    "code": "C4CD57",
    "usage_count": -2,
    "usage_count_limit": -1,
    "price_tier_id": 1,
    "discount_type": "fixed",
    "percentage": "0.1",
    "condition": "simple",
    "apply_target": "once",
    "begin_at": "2015-12-25",
    "expired_at": "2199-12-31",
    "user_usage_count_limit": -1,
    "base_price_type": "original",
    "coupon_rules": [
      {
        "id": 25,
        "quantity": 1,
        "condition": "include_product_models",
        "threshold_prices": null,
        "designer_ids": [],
        "product_model_ids": [
          4
        ],
        "product_category_ids": [],
        "work_gids": []
      }
    ]
  }
}

@apiErrorExample {json} 錯誤:
  HTTP/1.1 400 Bad Request
  {
    "error": "無法使用該優惠代碼",
    "code": "InvalidCouponError"
  }
=end
  def validate
    @coupon = Coupon.find_valid(params[:code], current_user)
    render 'show'
  end
end
