require 'json'
require 'digest'
require 'httparty'

# Guanyi 管易 Api Doc: http://gop.guanyierp.com/document/base.htm
class GuanyiService
  URL = 'http://v2.api.guanyierp.com/rest/erp_open'

  def initialize
    @settings = {
      appkey: Settings.guanyi.appkey,
      sessionkey: Settings.guanyi.sessionkey,
      secret: Settings.guanyi.secret
    }
  end

  def request_params(method, hash_params)
    {
      appkey: @settings[:appkey],
      sessionkey: @settings[:sessionkey],
      method: method, # EX: 'gy.erp.items.get'
    }.merge hash_params
  end

  # service = GuanyiService.new
  # res = service.request('gy.erp.items.get', page_no: 1, page_size: 50)
  # res # hash
  def request(method, params)
    res = JSON.parse(execute(method, params).body, symbolize_names: true)
    fail GuanyiError, full_error_messages(res) unless res[:success]
    res
  end

  private

  def full_error_messages(res)
    %i(errorCode subErrorCode errorDesc subErrorDesc).map do |code|
      "#{code}: #{res[code]}"
    end.join(', ')
  end

  def execute(method, params)
    body = post_body(request_params(method, params))
    headers = { 'Content-Type' => 'application/json' }
    HTTParty.post(URL, body: body, headers: headers)
  end

  def post_body(hash_params)
    secret = @settings[:secret]
    base = "#{secret}#{hash_params.to_json}#{secret}"
    sign = Digest::MD5.hexdigest(base).upcase
    hash_params.merge(sign: sign).to_json
  end
end
