class Guanyi::Trade
  attr_accessor :guanyi_service

  def initialize
    @guanyi_service = GuanyiService.new
  end

  def get_by_platform_code(platform_code)
    (wrap_response get(platform_code: platform_code)).orders.first
  end

  def get(params)
    response = guanyi_service.request('gy.erp.trade.get', params)
    fail GuanyiNotFoundError, params.to_s if not_found?(response)
    response
  end

  private

  def wrap_response(response)
    Hashie::Mash.new(response)
  end

  def not_found?(response)
    response[:total] == 0
  end
end
