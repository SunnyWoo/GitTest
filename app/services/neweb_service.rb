class NewebService
  include NewebHelper

  DEFAULT_OPTIONS = {
    hostname:       Settings.neweb.hostname,
    merchantnumber: Settings.neweb.merchantnumber,
    code:           Settings.neweb.code
  }

  def initialize(options = {})
    @options = DEFAULT_OPTIONS.merge(options.symbolize_keys)
  end

  def hostname
    @options[:hostname]
  end

  def merchantnumber
    @options[:merchantnumber]
  end

  def code
    @options[:code]
  end

  # 藍新接收付款 API 網址
  # 可用表單 (returnvalue=0) 或 HTTP client (returnvalue=1) POST
  def payment_url
    "http://#{hostname}/CashSystemFrontEnd/Payment"
  end

  # 接收付款需要的參數
  # 可塞在表單 (透過 hidden field) 或 HTTP POST body
  def payment_params(options = {})
    options = options.symbolize_keys
    check_required_fields(options, :ordernumber, :amount, :paymenttype,
                                   :paytitle, :paymemo)
    {
      merchantnumber: merchantnumber,
      ordernumber:    options[:ordernumber],
      amount:         options[:amount],
      paymenttype:    options[:paymenttype],
      paytitle:       options[:paytitle],
      paymemo:        options[:paymemo],
      bankid:         '007',
      duedate:        options[:duedate].try(:strftime, '%Y%m%d'),
      payname:        options[:payname],
      payphone:       options[:payphone],
      returnvalue:    options[:returnvalue] || '1',
      hash:           md5(merchantnumber, code, options[:amount], options[:ordernumber]),
      nexturl:        options[:nexturl] || '',
      mobile:         options[:mobile] || '0'
    }
  end

  # 驗證銷帳回傳值的正確性
  def valid_write_off_response?(response)
    hash = /&hash=([0-9a-f]{32})/.match(response)[1]
    response_without_hash = response.gsub(/&hash=[0-9a-f]{32}/, '')
    write_off_hash(response_without_hash) == hash
  end

  def valid_write_off_params?(params)
    # 重新排序 hash keys
    params = params.slice(*%w(merchantnumber ordernumber serialnumber
                              writeoffnumber timepaid paymenttype amount tel
                              hash))
    server_hash = params.delete('hash')
    client_hash = write_off_hash(params)
    server_hash == client_hash
  end

  # 藍新查詢付款 API 網址
  def query_url
    "http://#{hostname}/CashSystemFrontEnd/Query"
  end

  def regetorder_params(options = {})
    options = options.symbolize_keys
    check_required_fields(options, :ordernumber, :amount, :paymenttype)

    {
      merchantnumber:   merchantnumber,
      ordernumber:      options[:ordernumber],
      amount:           options[:amount],
      paymenttype:      options[:paymenttype],
      bankid:           '007',
      hash:             md5(merchantnumber, code, options[:amount], options[:ordernumber]),
      returnvalue:      options[:returnvalue] || '1',
      operation:        'regetorder',
      nexturl:          options[:nexturl] || '',
      responseencoding: options[:responseencoding] || 'UTF-8'
    }
  end

  def queryorders_params(options = {})
    time = to_neweb_time(Time.now)
    {
      merchantnumber:   merchantnumber,
      ordernumber:      options[:ordernumber],
      writeoffnumber:   options[:writeoffnumber],
      paymenttype:      options[:paymenttype],
      timecreateds:     to_neweb_date(options[:timecreateds]),
      timecreatede:     to_neweb_date(Date.today),
      status:           options[:status] || '0',
      operation:        'queryorders',
      time:             time,
      hash:             md5('queryorders', code, time),
      responseencoding: 'UTF-8'
    }
  end

  # 藍新取消付款 API 網址
  def cancel_order_url
    "http://#{hostname}/CashSystemFrontEnd/CancelOrderServlet"
  end

  # 產生銷帳資料的 hash
  def write_off_hash(response)
    if response.is_a?(Hash)
      response = response.map { |x, y| "#{x}=#{y}" }.join('&')
    end
    md5(response, code)
  end

  # 產生完整的銷帳回傳值
  def append_write_off_hash(response)
    "#{response}&hash=#{write_off_hash(response)}"
  end
end
