class Api::V3::RegistrationsController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {post} /api/sign_up Sign up with email or phone and password
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Registrations
@apiName SingUp
@apiParam {String} login email or phone
@apiParam {String} [code] phone verify code(only Region china)
@apiParam {String} password password
@apiParam {String} password_confirmation password_confirmation
@apiUse V3_UserResponse
=end
  def create
    if login_by_email?
      auth = EmailAuthentication.new(params.merge!(skip_notification: true))
    else
      # XXX: Hack - 因為 https://app.asana.com/0/9672537926113/97725435292479，
      # 當沒有 code parameter 時要先略過。等 Android 上新版後可以 rollback
      if params[:code].present?
        service = MobileVerifyService.new(params[:login])
        auth = MobileSignUpService.new(service, params)
      else
        @user = User::MobileSignUp.new(
          mobile: params[:login], password: params[:password], password_confirmation: params[:password_confirmation],
          confirmed_at: Time.zone.now
        ).save!
        setup_user(@user)
        return render 'api/v3/profiles/show'
      end
    end
    setup_user(auth.user)
    @user = auth.user
    render 'api/v3/profiles/show'
  end

  private

  def login_by_email?
    EmailValidator.valid?(params[:login])
  end

  def setup_user(user)
    user.logcraft_user = user
    user.create_activity(:sign_up)
  end
end
