class Mobile::SendMarketingService
  COMPANY = '噗印商城'

  # 亿美单条短信最长500字,超过70字，按67字一条扣费
  # 70字符按一条短信计算
  MESSAGE_SIZE = 52

  def initialize(operator, options = {})
    @operator = operator
    @send_type = options['send_type']
    @test_phone = options['test_phone']
    @message = options['content']
    @text = render_text
  end

  def execute
    activity = @operator.create_activity(:mobile_send_marketing,
                                         message: render_text,
                                         status: :fail, send_type: @send_type)
    case @send_type
    when 'production'
      # 亿美批量发送一般200个号码一个包
      User.select(:id, :mobile).where.not(mobile: nil, confirmed_at: nil).find_in_batches(batch_size: 200) do |users|
        send_sms(users.map(&:mobile), activity)
      end
    when 'test'
      send_sms(@test_phone.split(','), activity)
    end
  end

  protected

  def send_sms(mobiles, activity)
    ChinaSMS.use :emay, username: Settings.emay.marketing.cdkey, password: Settings.emay.marketing.password
    result = ChinaSMS.to mobiles, @text
    if result[:code] != '0'
      error_message = "Send SMS Failed [emay-error-code:#{result[:code]}]"
      activity.extra_info.fail_amount = activity.extra_info.fail_amount.to_i + mobiles.count
      activity.extra_info.error_message = error_message
      activity.save!
      fail ApplicationError, error_message
    else
      activity.extra_info.success_amount = activity.extra_info.success_amount.to_i + mobiles.count
      activity.save!
      result
    end
  end

  def render_text
    fail ApplicationError "Message Is Too Long, Max Length Is #{MESSAGE_SIZE}" if @message.size > MESSAGE_SIZE
    fail ApplicationError 'Message Is Empty' if @message.blank?
    "【#{COMPANY}】亲爱的用户，#{@message}回复TD退订" # 亿美短信格式：【签名】+ 内容 + 回复TD退订
  end
end
