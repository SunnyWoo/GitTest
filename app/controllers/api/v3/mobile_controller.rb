class Api::V3::MobileController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :find_service, except: :code

=begin
@api {get} /api/mobile/code Get 手機驗證碼
@apiDescription 目前只支援大陸手機號碼
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Mobile
@apiName GetMobileCode
@apiParam {String} mobile Mobile number, ex: '18516109323'
@apiParam {String="register", "reset_password"} usage usage of code
@apiSuccessExample {json} Success-Response:
  {
    "data": {
      "msg": "Verification code is sent.",
      "code": "135123",
      "expire_in": 120 # the code will expire in 120 seconds.
    }
  }
@apiError (Error 400) ApplicationError The <code>mobile</code> number is not valid
@apiError (Error 400) MobileRegisteredError The phone is registered
@apiError (Error 400) MobileUnregisteredError The phone is not registered
=end
  def code
    service = MobileSendCodeService.new(params)
    service.retrieve_and_send
    render json: { data: { msg: service.msg,
                           code: service.code,
                           expire_in: service.expire_in } },
           status: :ok
  end

=begin
@api {post} /api/mobile/verify Verify 手機驗證碼
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Mobile
@apiName VerifyMobileCode
@apiParam {String} mobile   Mobile number, ex: '18516109323'
@apiParam {String} code     Code for verify, ex: '134513'
@apiSuccessExample {json} Success-Response
  {
    "data": {
      "verified": true # or false
    }
  }
@apiError (Error 400) ApplicationError The <code>mobile</code> number is not valid
=end
  def verify
    verified = @service.verify(params[:code])
    render json: { data: { verified: verified } }, status: :ok
  end

=begin
@api {post} /api/mobile/forget_password Forget password
@apiDescription 忘记密码的手机验证码
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Mobile
@apiName MobileForgetPassword
@apiParam {String} mobile Mobile number, ex: '18516109323'
@apiSuccessExample {json} Success-Response:
  {
    "data": {
      "msg": "Verification code is sent.",
      "code": "135123",
      "expire_in": 120, # the code will expire in 120 seconds.
    }
  }
@apiError (Error 400) ApplicationError The <code>mobile</code> number is not valid
@apiError (Error 404) RecordNotFoundError The <code>user</code> is not found
=end
  def forget_password
    User.find_by!(mobile: @service.mobile)
    retrieve_and_send(@service)
  end

=begin
@api {post} /api/mobile/reset_password Reset password
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Mobile
@apiParamExample {json} Request-Example:
  {
    "mobile": "18516109323",
    "code": "134513",
    "passsword": "commandp",
    "password_confirmation": "commandp"
  }
@apiSuccessExample {json} Success-Response:
  {
    "data": {
      "msg": "Password changed",
    }
  }
@apiError (Error 400) {ApplicationError} mobile The <code>mobile</code> number is not valid
@apiError (Error 401) {MobileVerificationFailedError} code The mobile verification failed
@apiError (Error 404) {RecordNotFoundError} mobile The <code>user</code> is not found
@apiError (Error 400) {ParametersInvalidError} password  parameter password need
@apiError (Error 422) {RecordInvalidError} password_confirmation password confirmation failed
=end
  def reset_password
    fail MobileVerificationFailedError unless @service.verify(params[:code])
    user = User.find_by!(mobile: @service.mobile)
    user.update_attributes!(password_params)
    render json: { data: { msg: 'Password changed' } }, status: :ok
  end

  private

  def find_service
    @service = MobileVerifyService.new(params[:mobile])
  end

  def retrieve_and_send(service)
    @code = service.retrieve_code
    service.send_code
    msg = 'Verification code is sent.'
    render json: { data: { msg: msg, code: @code, expire_in: service.expire_in } }, status: :ok
  end

  def password_params
    fail ParametersInvalidError, caused_by: 'password' unless params[:password] && params[:password_confirmation]
    params.permit(:password, :password_confirmation)
  end
end
