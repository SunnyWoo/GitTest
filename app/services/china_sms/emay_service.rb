class ChinaSms::EmayService < SmsService
  RETURN_CODES = {
    '0' => '短信发送成功',
    '17' => '发送信息失败',
    '18' => '发送定时信息失败',
    '101' => '客户端网络故障',
    '305' => '服务器端返回错误，错误的返回值(返回值不是数字字串符)',
    '307' => '目标电话号码不符合规则，电话号码必须是以0、1开头',
    '997' => '目标电话号码不符合规则，电话号码必须是以0、1开头',
    '998' => '由于客户端网络问题导致信息发送超时，该信息是否成功下发送无法确定'
  }
  TYPES = %w(captcha marketing)

  def initialize(type: 'captcha')
    fail ApplicationError, 'china sms type error' unless TYPES.include?(type)
    ChinaSMS.use :emay, username: Settings.emay.captcha.cdkey, password: Settings.emay.captcha.password
  end

  def execute(phones, content, _options = {})
    valid_phones, invalid_phones = filter_phones(phones)
    res = sms_fire(valid_phones, content)
    format_result(res).merge(invalid_phones: invalid_phones)
  end

  protected

  def sms_fire(phones, content)
    ChinaSMS.to phones, content
  end

  def format_result(res)
    result = if res[:code] == '0'
               { status: 'Ok', message: RETURN_CODES[res[:code]] }
             else
               { status: 'Fail', message: RETURN_CODES[res[:code]] }
             end
    default_format_result.merge(result)
  end
end
