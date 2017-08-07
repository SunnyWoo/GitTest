class SmsKingService < SmsService
  ERROR_CODES = {
    '-1' => 'CGI string error ，系統維護中或其他錯誤 ,帶入的參數異常,伺服器異常',
    '-2' => ' 授權錯誤(帳號/密碼錯誤)',
    '-4' => ' A Number違反規則 發送端 870短碼VCSN 設定異常',
    '-5' => 'B Number違反規則 接收端 門號錯誤 -',
    '-6' => 'Closed User 接收端的門號停話異常090 094 099 付費代號等',
    '-20' => 'Schedule Time錯誤 預約時間錯誤 或時間已過',
    '-21' => 'Valid Time錯誤 有效時間錯誤',
    '-59999' => '帳務系統異常 簡訊無法扣款送出',
    '-60002' => '您帳戶中的點數不足',
    '-60014' => '該用戶已申請 拒收簡訊平台之簡訊 ( 2010 NCC新規)',
    '-999959999' => '在12 小時內，相同容錯機制碼',
    '-999969999' => '同秒, 同門號, 同內容簡訊',
    '-999979999' => '鎖定來源IP',
    '-999989999' => '簡訊為空'
  }

  def initialize
    @username = Settings.SMS.sms_king.username
    @password = Settings.SMS.sms_king.password
  end

  # phones可以是用,隔開的字串或是字串陣列
  # 當一次傳給多人時，即使當中有號碼因為錯誤未能送達對方API也只會回傳true，必須自己去後台才能看到詳細結果
  # 所以自己先排過濾一次並且把格式不對的號碼加入到回傳結果比較靠譜
  def execute(phones, content, options={})
    valid_phones, invalid_phones = filter_phones(phones)
    params = {
      username: @username,
      password: @password,
      dlvtime: '0', # 0為立即寄送
      smbody: big5_format(content),
      dstaddr: valid_phones
    }
    res = sms_fire(params)
    format_result(res).merge(invalid_phones: invalid_phones)
  end

  private

  def sms_fire(params)
    tag = params[:dstaddr].split(',').size.in? (0..1)
    url = tag ? Settings.SMS.sms_king.url : Settings.SMS.sms_king.multiple_pass_url
    HTTParty.get(url, query: params)
  end

  def format_result(res)
    result = if code = res.to_s.match(/kmsgid=([-]?\d+)\n/)
               if code[1][0] == '-'
                 { status: 'Fail', message: ERROR_CODES[code[1]] }
               else
                 { status: 'Ok', message: '已傳送' }
               end
             else
               { status: 'Fail', message: '未提供號碼' }
             end
    default_format_result.merge(result)
  end

  def big5_format(content)
    Iconv.new('big5', 'utf8').iconv(content)
  end
end
