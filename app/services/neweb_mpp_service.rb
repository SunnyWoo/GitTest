class NewebMPPService
  include NewebHelper

  DEFAULT_OPTIONS = {
    hostname:       Settings.neweb_mpp.hostname,
    merchantnumber: Settings.neweb_mpp.merchantnumber,
    code:           Settings.neweb_mpp.code
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

  def payment_url(params = nil)
    base_url = "https://#{hostname}/NewebmPP/cdcard.jsp"
    if params.present?
      "#{base_url}?#{params.to_query}"
    else
      base_url
    end
  end

  def payment_params(options = {})
    check_required_fields(options, :ordernumber, :amount, :orderurl, :returnurl)
    {
      merchantnumber: merchantnumber,
      ordernumber:    options[:ordernumber],
      amount:         options[:amount],
      depositflag:    '1',
      approveflag:    '1',
      englishmode:    '0',
      orderurl:       options[:orderurl],
      returnurl:      options[:returnurl],
      checksum:       md5(merchantnumber, options[:ordernumber], code, options[:amount]),
      op:             'AcceptPayment'
    }
  end

  def valid_return_params?(params)
    expect_checksum = md5(params['P_MerchantNumber'],
                          params['P_OrderNumber'],
                          params['final_result'],
                          params['final_return_PRC'],
                          code,
                          params['final_return_SRC'],
                          params['P_Amount'])
    actual_checksum = params['P_CheckSum']
    expect_checksum == actual_checksum
  end

  def valid_callback_params?(params)
    expect_checksum = md5(params['MerchantNumber'],
                          params['OrderNumber'],
                          params['PRC'],
                          params['SRC'],
                          code,
                          params['Amount'])
    actual_checksum = params['CheckSum']
    expect_checksum == actual_checksum
  end
end
