class Api::V1::SearchController < ApiController
  # Get Country Code
  #
  # Url : /api/country_code
  #
  # RESTful : GET
  #
  # Get Example
  #   /api/country_code
  #
  # Return Example
  #   {
  #     "ip":"127.0.0.1",
  #     "country_code":"US"
  #   }
  #
  # @return [JSON] status 200
  def country_code
    render json: {
      ip: client_ip,
      country_code: country_code_by_ip(client_ip)
    }
    fresh_when(etag: client_ip)
  end
end
