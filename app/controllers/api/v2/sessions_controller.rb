class Api::V2::SessionsController < ApiV2Controller
  before_action :authenticate_required!, only: [:destroy]
  before_action :find_sign_in_method, only: [:create]

=begin
@api {post} /api/sign_in Email 登入
@apiUse AuthSuccess
@apiGroup Login
@apiName NormalUserSignInEmail
@apiVersion 2.0.0
@apiParam {String="normal"} way 驗證方式
@apiParam {String} email 登入 email
@apiParam {String} password_input
@apiParamExample {json} Request-Example
  POST /api/sign_in
  {
    "way": "normal",
    "email": "a_valid_user@gmail.com",
    "password_input": "commandp",
  }
=end
=begin
@api {post} /api/sign_in Mobile 登入
@apiUse AuthSuccess
@apiGroup Login
@apiName NormalUserSignInMobile
@apiVersion 2.0.0
@apiParam {String="normal"} way 驗證方式
@apiParam {String="mobile"} sign_in_method 登入方式
@apiParam {String} mobile 登入手機, ex: 18516107492
@apiParam {String} password_input
@apiParamExample {json} Request-Example
  POST /api/sign_in
  {
    "way": "normal",
    "sign_in_method": "mobile",
    "mobile": "12345678901",
    "password_input": "commandp",
  }
=end
  def create
    auth_class = 'email' == @sign_in_method ? EmailAuthentication : MobileAuthService
    auth = auth_class.new(params)
    do_login_user(auth.user)
    render json: auth.user, serializer: Api::V2::AuthSerializer, root: :user, status: :ok
  end

=begin
@api {delete} /api/sign_out Normal 登出
@apiUse UserSignOut
@apiParam {String} auth_token User auth token
@apiGroup Logout
@apiName NormalUserSignOut
@apiVersion 2.0.0
=end
  def destroy
    current_user.auth_tokens.where(token: params[:auth_token]).destroy_all
    log_with_current_user current_user
    current_user.create_activity(:sign_out)
    sign_out current_user
    render json: { status: 'success', message: 'Sign out success' }
  end

  protected

  def find_sign_in_method
    @sign_in_method = %w(email mobile).include?(params[:sign_in_method]) ? params[:sign_in_method] : 'email'
  end

  def do_login_user(user)
    user.generate_token
    sign_in :user, user
    user.create_activity(:sign_in)
  end
end
