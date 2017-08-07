class SfExpressService
  include SfExpress::Helper::Sign
  include SfExpress::Helper::ErrorCode

  # 由于aws上面config setting无法使用中文
  # 所以将下面几个不太会改动的写在代码里
  J_ADDRESS = '台北市松山區南京東路五段16號3樓'
  J_COMPANY = '我印網路科技股份有限公司'
  J_POST_CODE = 105
  J_SHIPPERCODE = 886

  class_attribute :mappings
  attr_accessor :order

  def self.inherited(subclass)
    subclass.mappings ||= {}
  end

  def self.mapping(attribute, options = {})
    mappings[attribute] = options
  end

  def execute
    response_xml = RestClient.post(Settings.sf_express.url, request_params)
    result(Hash.from_xml(response_xml))
  rescue => e
    fail ApplicationError, e.message
  end

  def error_result(error)
    if error.is_a?(Hash) && error.key?('code')
      message = error_message(error['code'])
    else
      message = error.to_s
    end
    { 'error' => message }
  end

  protected

  # 删除_SYSTEM的param，使用系统配置获取
  def check_params(params)
    params.delete_if { |_key, value| value.in? ['_SYSTEM', nil] }
  end

  def request_params
    xml = request_xml
    { xml: xml, verifyCode: verify_code(xml) }
  end
end
