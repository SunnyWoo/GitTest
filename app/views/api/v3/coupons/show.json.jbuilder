cache_json_for json, @coupon do
  json.coupon do
    json.partial! 'api/v3/coupon', coupon: @coupon
  end
end
