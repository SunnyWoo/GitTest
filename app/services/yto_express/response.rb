class YtoExpress::Response
  ERROR_CODE = {
    'S01' => '订单报文不合法',
    'S02' => '数字签名不匹配',
    'S03' => '没有剩余单号',
    'S04' => '接口请求参数为空',
    'S05' => '唯品会专用',
    'S06' => '请求太快',
    'S07' => 'url解码失败',
    'S08' => '订单号重复',
    'S09' => '数据入库异常',
  }.freeze

  attr_reader :response

  def initialize(response_xml)
    @response = Hash.from_xml(response_xml)['Response']
  end

  def body
    return failed_body if invalid?
    success_body
  end

  def failed_body
    {
      tx_logistic_id: nil,
      logistic_provider_id: 'YTO',
      code: code,
      success: false,
      error_type: error_type,
      reason: reason,
      repeat_order: repeat_order?
    }
  end

  def success_body
    {
      logistic_provider_id: logistic_provider_id,
      tx_logistic_id: tx_logistic_id,
      client_id: client_id,
      mail_no: mail_no,
      short_address: distribute_info['shortAddress'],
      consignee_branch_code: distribute_info['consigneeBranchCode'],
      package_center_code: distribute_info['packageCenterCode'],
      package_center_name: distribute_info['packageCenterName'],
      code: code,
      success: true
    }
  end

  def error_type
    ERROR_CODE[code]
  end

  def repeat_order?
    code == 'S08'
  end

  def invalid?
    ERROR_CODE.keys.include?(code)
  end

  def code
    response['code']
  end
  alias_method :status, :code

  def reason
    response['reason']
  end

  def mail_no
    response['mailNo']
  end

  def distribute_info
    response['distributeInfo'] || {}
  end

  def success
    response['success']
  end

  def client_id
    response['clientID']
  end

  def tx_logistic_id
    response['txLogisticID']
  end

  def logistic_provider_id
    response['logisticProviderID']
  end
end
