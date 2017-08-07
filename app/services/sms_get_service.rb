class SmsGetService < SmsService
  URL = Settings.SMS.sms_get.url

  ERROR_CODES = {
    '000' => '成功',
    '001' => '參數錯誤',
    '002' => '預約時間參數錯誤',
    '003' => '預約時間過期',
    '004' => '訊息長度過長',
    '005' => '帳號密碼錯誤',
    '006' => 'IP 無法存取',
    '007' => '收件者人數為 0',
    '008' => '收件人超過 250 人',
    '009' => '點數不足'
  }

  def initialize
    @username = Settings.SMS.sms_get.username
    @password = Settings.SMS.sms_get.password
  end

  # phones可以是用,隔開的字串或是字串陣列
  # 當一次傳給多人時，即使當中有號碼因為錯誤未能送達對方API也只會回傳true，必須自己去後台才能看到詳細結果
  # 所以自己先排過濾一次並且把格式不對的號碼加入到回傳結果比較靠譜
  def execute(phones, content, _options={})
    valid_phones, invalid_phones = filter_phones(phones)
    params = {
      body: {
        username: @username,
        password: @password,
        method: '1', # 預設為立即寄送
        sms_msg: content,
        phone: valid_phones
      }
    }
    res = sms_post_body(URL, params)
    format_result(res).merge(invalid_phones: invalid_phones)
  end

  private

  def sms_post_body(url, params)
    HTTParty.post(url, params).body
  end

  def format_result(res)
    res = JSON.parse(res)
    # 回傳範例
    # {"stats"=>true, "error_code"=>"000", "error_msg"=>"795938|1|29864"}
    # 其中 error_msg 格式為 訊息 ID |使用點數|剩餘點數，我只關心剩餘點數所以僅回傳剩餘點數
    result = if res['stats'] == true
               { status: 'Ok' }
             else
               {
                 status: 'Fail',
                 message: ERROR_CODES[res['error_code']]
               }
             end
    default_format_result.merge result
  end
end
