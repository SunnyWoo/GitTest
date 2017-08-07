class Yonyou::Request
  attr_accessor :base_params

  def initialize
    @base_params = {
      from_account: Settings.yonyou.from_account,
      app_key: Settings.yonyou.app_key
    }
  end

  def get(url, params = {})
    params.merge! base_params
    wrap_get_response HTTParty.get(url, query: params)
  end

  def post(url, query = {}, body = {})
    query.merge! base_params
    headers = { 'Content-Type' => 'application/json' }
    wrap_post_response HTTParty.post(url, query: query, body: body.to_json, headers: headers)
  end

  private

  def wrap_get_response(response)
    response = Hashie::Mash.new(response)
    fail YonyouError, response if get_request_error?(response)
    response
  end

  def wrap_post_response(response)
    response = Hashie::Mash.new(response)
    fail YonyouError, response if post_request_error?(response)
    response
  end

  def get_request_error?(response)
    response.errcode != 0
  end

  def post_request_error?(response)
    !(response.errcode == 0 || response.tradeid.to_b)
  end
end
