class Api::V3::CountryCodesController < ApiV3Controller
=begin
@api {get} /api/country_code Get country code
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Country Code
@apiName Country Code
@apiSuccessExample {json} Response-Example:
  {
    "ip": "127.0.0.1",
    "country_code": "US"
  }
=end
  def show
    render json: {
      ip: params[:remote_ip] || client_ip,
      country_code: country_code_by_ip(params[:remote_ip] || client_ip)
    }
    fresh_when(etag: client_ip)
  end
end
