class MobileSendCodeService
  attr_reader :code, :msg, :expire_in

  def initialize(args)
    @mobile = args[:mobile].to_s
    @usage = args.fetch(:usage, :register)
  end

  def retrieve_and_send
    verify_usage
    mobile_service = MobileVerifyService.new(@mobile)
    @code ||= mobile_service.retrieve_code
    mobile_service.send_code
    @expire_in = mobile_service.expire_in
    @msg = I18n.t('verification_code_is_sent')
  end

  private

  def verify_usage
    user = User.find_by(mobile: @mobile)
    case @usage.try(:to_sym)
    when :register
      fail MobileRegisteredError if user
    when :reset_password
      fail MobileUnregisteredError unless user
    when :simple
      # do nth, For simple regist flow on waterpackage campaign
    else
      fail ApplicationError, 'send failed'
    end
  end
end
