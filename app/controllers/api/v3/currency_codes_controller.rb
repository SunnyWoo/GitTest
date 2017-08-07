class Api::V3::CurrencyCodesController < ApiV3Controller
  before_action :doorkeeper_authorize!
=begin
@api {get} /api/currency_code Get currency code
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Currency Code
@apiName Currency Code
@apiParam {String} remote_ip remote_ip can be nil
@apiSuccessExample {json} Response-Example:
  {
    "ip": "127.0.0.1",
    "currency_code": "CNY"
    "currency_list": {
         "TW" => "TWD",
         "CN" => "CNY",
         "JP" => "JPY",
         "HK" => "HKD",
         "default" => "USD"
     }
  }
=end
  def show
    render json: {
      ip: params[:remote_ip] || remote_ip,
      currency_code: current_currency_code,
      currency_list: CurrencyType::COUNTRY_CURRENCY_MAPPING
    }
    fresh_when(etag: remote_ip)
  end

  private

  def current_country_code
    @current_country_code ||= country_code_by_ip(params[:remote_ip] || request.remote_ip)
  end
end
