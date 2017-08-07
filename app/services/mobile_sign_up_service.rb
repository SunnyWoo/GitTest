class MobileSignUpService
  attr_reader :service

  def initialize(service, params)
    @service = service
    @code = params[:code]
    @password = params[:password]
    @password_confirmation = params[:password_confirmation]
  end

  def user
    return @user if @user
    fail MobileVerificationFailedError unless service.verify(@code)
    @user = User::MobileSignUp.new(
      mobile: service.mobile, password: @password, password_confirmation: @password_confirmation,
      confirmed_at: Time.zone.now
    ).save!
  end
end
