class Api::V2::CouponsController < ApiV2Controller
=begin
@api {get} /api/validate Coupon validate
@apiParam {String} code  The coupon, ex: `WELCOM6`
@apiVersion 2.0.0
@apiGroup Coupons
@apiName ValidateCoupon
@apiSuccess {Object[]} coupon     Coupon 內容
@apiSuccess {String} coupon.title Coupon 標題
@apiSuccess {String} coupon.code  Coupon code
@apiSuccess {String="fixed","percentage","threshold","include_product_models"} coupon.discout_type 折價類別
@apiSuccess {Object[]} [coupon.prices] Coupon 價格, 當 `discount_type` 為 `fixed` 時出現
@apiSuccess {Float} [coupon.percentage] 折價比例, 當 `discount_type` 為 `percentage` 時出現
@apiSuccess {Object[]} [coupon.threshold] Threshold, 當 `discount_type` 為 `threshold` 時出現
@apiSuccess {Array[Integer]} [coupon.product_model_ids] Product Model Id, 當 `discount_type` 為 `include_product_models` 時出現
@apiSuccess {String="once","per_item"} [coupon.apply_target] Apply target, 當 `discount_type` 為 `include_product_models` 時出現
@apiSuccess {String} coupon.begin_at Coupon 開始日期
@apiSuccess {String} coupon.expired_at Coupon 結束日期
@apiSuccessExample {json} 回傳(fixed):
  {
    "coupon": {
      "title": "hello coupon",
      "code": "WELCOME6",
      "discount_type": "fixed",
      "prices": { "TWD": 150, "USD": 5 },
      "begin_at": "2015-02-04",
      "expired_at": "2015-02-14"
    }
  }
@apiSuccessExample {json} 回傳(percentage):
  {
    "coupon": {
      "title": "hello coupon",
      "code": "WELCOME6",
      "discount_type": "percentage",
      "percentage": "0.2",
      "begin_at": "2015-02-04",
      "expired_at": "2015-02-14"
    }
  }
@apiSuccessExample {json} 回傳(threshold):
  {
    "coupon": {
      "title": "hello coupon",
      "code": "WELCOME6",
      "condition": "threshold",
      "threshold": { "TWD": 100, "USD": 3 },
      "begin_at": "2015-02-04",
      "expired_at": "2015-02-14"
    }
  }
@apiSuccessExample {json} 回傳(include_product_models):
  {
    "coupon": {
      "title": "hello coupon",
      "code": "WELCOME6",
      "condition": "include_product_models",
      "product_model_ids": [1, 2, 3],
      "apply_target": "once", # or "per_item"
      "begin_at": "2015-02-04",
      "expired_at": "2015-02-14"
    }
  }
@apiSuccessExample {json} 回傳(none):
  {
    "coupon": {
      "title": "hello coupon",
      "code": "WELCOME6",
      "condition": "none",
      "begin_at": "2015-02-04",
      "expired_at": "2015-02-14"
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
    render json: @coupon, serializer: Api::V2::CouponSerializer
  end
end
