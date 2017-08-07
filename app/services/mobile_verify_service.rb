class MobileVerifyService
  EXPIRE_SECONDS = 120 # code有效期120s， 120秒內只允許送出一次 sns
  COMPANY = '噗印商城'.freeze # 要改這字串必須要先去 亿美 送審

  attr_reader :mobile

  class << self
    def redis
      server = Redis.new(url: Settings.Redis.url)
      @redis ||= Redis::Namespace.new(:mobile, redis: server)
    end
  end

  def redis
    self.class.redis
  end

  def initialize(mobile)
    res = mobile.to_s
    fail MobileNumberError unless res =~ /^[0-9]+$/
    @mobile = res
  end

  def expire_in
    redis.ttl(@mobile).seconds
  end

  def retrieve_code
    redis.get(@mobile) || generate_code
  end

  def verify(code)
    code.to_s == retrieve_code
  end

  def cleanup
    redis.del @mobile
  end

  def send_code
    return true if redis.get("#{@mobile}:sns_sent")
    result = if Region.china?
               # 中國簡訊內容格式需要先送審才可以寄
               SmsService.new(provider: :emay).execute(@mobile, "【#{COMPANY}】您的验证码是#{retrieve_code}")
             else
               SmsService.new(provider: :sms_king).execute(@mobile, "我印您好，您的驗證碼是: #{retrieve_code}")
             end
    if result[:status] =~ /ok/i
      redis.set("#{@mobile}:sns_sent", 'true', ex: EXPIRE_SECONDS)
      Logcraft::Activity.create(key: 'mobile_code_sent', trackable_type: 'SmsService', extra_info: { mobile: @mobile })
      result
    else
      Logcraft::Activity.create(key: 'mobile_code_sent_error',
                                trackable_type: 'SmsService',
                                extra_info: { mobile: @mobile, result: result })
      fail MobileNumberError
    end
  end

  private

  def generate_code
    code = random_code.to_s
    redis.set(@mobile, code, ex: EXPIRE_SECONDS)
    code
  end

  def random_code
    rand.to_s[2..7]
  end
end
