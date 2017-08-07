class Api::V2::RegistrationsController < ApiV2Controller
  before_action :find_register_method
=begin
@api {post} /api/sign_up Email 註冊
@apiUse AuthSuccess
@apiGroup Register
@apiName NormalUserSignUpEmail
@apiVersion 2.0.0
@apiParam {String="normal"} way 驗證方式
@apiParam {String} email 註冊 email
@apiParam {String} password
@apiParam {String} password_confirmation
@apiParamExample {json} Request-Example:
  POST /api/sign_up
  {
    "way": "normal",
    "email": "a_valid_user@gmail.com",
    "password": "commandp",
    "password_confirmation": "commandp"
  }
@apiError (Error 422) {RecordInvalidError} email 不能是空白字元或無效
@apiUse RegisterCommon
=end
=begin
@api {post} /api/sign_up 手機註冊
@apiUse AuthSuccess
@apiGroup Register
@apiName NormalUserSignUpMobile
@apiVersion 2.0.0
@apiParam {String="normal"} way 驗證方式
@apiParam {String="mobile"} register_method 註冊方式
@apiParam {String} mobile 註冊用的手機, ex: 18516107492
@apiParam {String} code 手機驗證碼, ex: 123456
@apiParam {String} password
@apiParam {String} password_confirmation
@apiParamExample {json} Request-Example:
  POST /api/sign_up
  {
    "way": "normal",
    "register_method": "mobile",
    "mobile": "12345678901",
    "code": "123456",
    "password": "commandp",
    "password_confirmation": "commandp"
  }
@apiError (Error 401) {MobileVerificationFailedError} mobile Mobile verification code error
@apiUse RegisterCommon
=end
  def create
    if 'email' == @register_method
      auth = EmailAuthentication.new(params.merge!(skip_notification: true))
      # Note
      # 因為現在 web 改成 v3, iOS email 註冊 還是用 V2, 驗證網址會錯誤 在這修改 驗證網址
      ConfirmationMailerWorker.perform_async(auth.user.id, root_url(:sign_in,
                                                                    host: Settings.action_mailer.default_url_options))
    else
      service = MobileVerifyService.new(params[:mobile])
      auth = MobileSignUpService.new(service, params)
      setup_user(auth.user)
    end

    render json: auth.user, serializer: Api::V2::AuthSerializer, root: :user, status: :ok
  end

  protected

  def find_register_method
    @register_method = %w(email mobile).include?(params[:register_method]) ? params[:register_method] : 'email'
  end

  def setup_user(user)
    user.generate_token
    sign_in :user, user
    migrate_guest_to_user(params[:old_auth_token], user) if params[:old_auth_token].present?
    log_with_current_user user
    user.logcraft_user = user
    user.create_activity(:sign_in)
  end

  def migrate_guest_to_user(old_auth_token, user)
    from_user = User.find_by(auth_token: old_auth_token)
    GuestToUserService.migrate_data(from_user, user) if from_user.present? && user.present?
  end
end
=begin
@apiDefine RegisterCommon
@apiError (Error 422) {RecordInvalidError} password password and password_confirmation is not consistent
=end
