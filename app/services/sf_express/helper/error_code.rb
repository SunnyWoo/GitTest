module SfExpress::Helper::ErrorCode
  MESSAGE = {
    '4001' => '系统发生数据错误或运行时异常',
    '4002' => '报文解析错',
    '6101' => '必填项为空',
    '6102' => '寄件方公司名称(j_company)为空',
    '6103' => '寄件方联系人(j_contact)为空',
    '6106' => '寄件方详细地址(j_address)为空',
    '6107' => '到件方公司名称(d_company)为空',
    '6108' => '到件方联系人(d_contact)为空',
    '6111' => '到件方详细地址(d_address)为空,下单失败',
    '6114' => '客户订单号(orderid)为空,筛单失败',
    '6117' => '到件方详细地址(d_address)为空,筛单失败',
    '6118' => '客户订单号(orderid)为空,下单失败',
    '6119' => '到件方联系电话(d_tel)为空',
    '6120' => '快件产品类别(express_type)为空',
    '6121' => '寄件方联系电话(j_tel)为空',
    '6122' => '筛单类别(filter_type)不合法',
    '6123' => '顺丰运单号(mailno)为空',
    '6124' => '付款方式(pay_method)为空',
    '6125' => 'Order/Cargo 元素必填项为空',
    '6126' => '顺丰月结卡号(custid)不合法',
    '6127' => '增值服务名(Order/AddedService 元素的name)为空',
    '6128' => '增值服务名(Order/AddedService 元素的name)不合法',
    '6129' => '付款方式(pay_method)不合法',
    '6130' => '订单货物总体积(volume)不合法',
    '6131' => '客户订单操作标识(dealtype)不合法',
    '6132' => '路由查询类别(method_type)不合法',
    '6133' => '查询号类别(tracking_type)不合法',
    '6134' => '请求XML报文不合法,筛单失败',
    '6135' => '请求XML报文不合法,下单失败',
    '6136' => '请求XML报文不合法,订单确认/取消失败',
    '6137' => '请求XML报文不合法,路由查询失败',
    '6138' => '代收货款金额(Order/AddedService元素的value)不合法',
    '6139' => '代收货款金额(Order/AddedService 元素的value)不合法,不能小于0',
    '6140' => '代收货款卡号(Order/AddedService 元素的value)为空',
    '6141' => '代收货款卡号(Order/AddedService 元素的value)不合法,未配置代收货款上限',
    '6142' => '代收货款金额(Order/AddedService 元素的value)不合法,超过代收货款上限',
    '6150' => '客户订单号(orderid)不存在',
    '8000' => '报文参数不合法',
    '8001' => 'IP未授权',
    '8002' => '未授权使用此接口',
    '8003' => '批量交易超上限(OrderFilter 元素)',
    '8004' => '批量交易超上限(查询号tracking_number)',
    '8005' => '接口调用次数超上限',
    '8009' => '客户订单不可以收派,确认订单失败',
    '8010' => '客户订单未筛单,确认订单失败',
    '8011' => '接入编码与顺丰运单号(mailno)不匹配',
    '8012' => '接入编码与客户订单号(orderid)不匹配',
    '8013' => '查询号(tracking_number)为空,路由查询失败',
    '8014' => '校验码错误',
    '8015' => '顺丰母运单号(main_mailno)为空,子单号申请失败',
    '8016' => '客户订单号(orderid)已存在',
    '8017' => '客户订单号(orderid)与顺丰运单号(mailno)不匹配',
    '8018' => '未获取到客户订单信息',
    '8019' => '客户订单号(orderid)已确认',
    '8020' => '不存在该客户订单号(orderid)跟顺丰运单号(mailno)的绑定关系',
    '8021' => '接入编码为空',
    '8023' => '服务名称为空',
    '8024' => '此客户订单号不存在对应的顺丰运单号,确认/取消失败',
    '8025' => '未传入服务名称或服务名称不合法',
    '8026' => '接入编码不存在',
    '8027' => '业务模板不存在',
    '8028' => '业务模板配置/属性未设置',
    '8029' => '默认业务模板未配置',
    '8030' => '业务模板不在生效日期范围内',
    '8031' => '数据错误,未找到业务模板',
    '8032' => '数据错误,未找到业务模板配置',
    '8033' => '数据错误,未找到业务模板属性',
    '8034' => '人工筛单结果推送已注册',
    '8035' => '顺丰运单号为空,客户订单自动确认失败',
    '8036' => '顺丰运单号为空,路由推送注册失败',
    '8037' => '客户订单号已取消',
    '8039' => '业务类型(business_type)不合法,时效查询失败',
    '8040' => '原寄地区域代码(code)无法获取,时效查询失败',
    '8041' => '目的地区域代码(code)无法获取,时效查询失败',
    '8042' => '寄件时间(consigned_time)不合法',
    '8066' => '新增加的包裹数(parcel_quantity)不合法,子单号申请失败',
    '8067' => '新增加的包裹数(parcel_quantity)超上限,子单号申请失败',
    '8068' => '顺丰运单号已经生成清单,子单号申请失败',
    '8069' => '客户订单不可以收派,子单号申请失败'
  }

  def error_message(code)
    code = code.to_s
    return code unless MESSAGE.key?(code)
    MESSAGE[code]
  end
end
