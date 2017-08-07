class SfExpress::Scope < SfExpressService
  # 产品及增值服务查询接口(业务服务范围查询接口)
  # example: SfExpress::Scope.new.execute
  # 此处只列取必填参数详细参数见 https://app.asana.com/0/42686877023074/52400225332580  附件
  # response
  #   success:
  #    {
  #     "Scope" => {
  #       "Service" => {
  #         "name" => "INSURE",
  #         "value" => "20000"
  #       }
  #     }
  #   }
  #
  #   error:
  #    {
  #      "error" => "系统发生数据错误或运行时异常"
  #    }

  mapping :scope, custid: Settings.sf_express.custid # 顺丰月结卡号

  def request_xml
    Gyoku.xml(
      'Request' => {
        'Head' => Settings.sf_express.code,
        'Body' => {
          'Scope' => '',
          :attributes! => { 'Scope' => check_params(mappings[:scope]) }
        }
      }, :attributes! => { 'Request' => { 'service' => 'ScopeService', 'lang' => 'zh-TW' } }
    )
  end

  def result(response_json)
    head = response_json['Response']['Head']
    if head == 'OK'
      response_json['Response']['Body']
    elsif head == 'ERR'
      error_result(response_json['Response']['ERROR'])
    else
      fail SfExpressError, response_json
    end
  end
end
