class YtoExpress::Request
  attr_reader :request_xml, :response

  def initialize(request_xml)
    @request_xml = request_xml
  end

  def post
    response_xml = RestClient.post(Settings.yto_express.url + "?#{request_url_query}", {})
    response_body(response_xml)
  end

  private

  def response_body(response_xml)
    @response = YtoExpress::Response.new(response_xml)
    @response.body
  end

  def request_params
    {
      clientId: Settings.yto_express.client_id,
      type: 'offline',
      data_digest: URI.escape(Base64.strict_encode64(Digest::MD5.digest(request_xml + Settings.yto_express.key))),
      logistics_interface: URI.escape(request_xml)
    }
  end

  def request_url_query
    Addressable::URI.new(query_values: request_params).query
  end
end
