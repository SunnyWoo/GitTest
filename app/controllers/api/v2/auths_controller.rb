=begin
@apiDefine AuthSuccess
@apiSuccessExample {json} Success-Response:
  {
    "user": {
      "user_id": 1,
      "auth_token": "9da385684af411e586ce3c15c2d24fd8",
      "email": "user1@commandp.me",
      "username": "User Name",
      "first_name": "Arnaldo",
      "last_name": "Brekke",
      "role": "normal",
      "mobile": 0910123456,
      "mobile_country_code": "TW",
      "avatar": {
        "use_default_image": true,
        "thumb": "/assets/img_fbdefault.png?v=1440485018",
        "normal": "/assets/img_fbdefault.png?v=1440485018"
      },
      "links": {
        "orders": {
          "url": "http://test.host/api/my/orders?locale=en",
          "accept": "application/commandp.v1"
        },
        "works": {
          "url": "http://test.host/api/my/works?locale=en",
          "accept": "application/commandp.v1"
        }
      },
      "birthday": "2000-10-10"
    }
  }
=end
=begin
@apiDefine UserSignOut
@apiSuccessExample {json} Success-Response:
  {
    "status": "Success",
    "message": "Sign out success"
  }
=end
class Api::V2::AuthsController < ApiV2Controller
  include MigrateGuestToUserHelper
  before_action :authenticate_required!, only: [:destroy]
  rescue_from OAuth2::Error, with: :handle_oauth2_error
=begin
@api {post} /api/sign_in OAuth 登入
@apiUse AuthSuccess
@apiGroup Login
@apiName OauthUserSignIn
@apiVersion 2.0.0
@apiParam {String="oauth"} way 驗證方式
@apiParam {String="facebook","twitter","google_oauth2","qq","wechat"} provider
@apiParam {Integer} uid       OAuth uid
@apiParam {String} access_token
@apiParam {String} [secret]   OAuth 1.1 may need this, like `twitter`
@apiParam {String} [email]    User email
@apiParam {String} [old_auth_token]  若要轉換 `Guest` to `User` 需要帶入
@apiParamExample {json} Request-Example
  POST /api/sign_in
  {
    "way": "oauth",
    "provider": "facebook",
    "uid": "fb123215123123",
    "access_token": "fbaccesstoken135kbdf03csdf",
    "email": "normaluser@fb.me"
  }
=end
  def create
    @auth = ApiAuthentication.new(params)
    if @auth.authenticated?
      @auth.sign_in
      user = @auth.user
      migrate_guest_to_user(params[:old_auth_token], user) if params[:old_auth_token]
      log_with_current_user user
      user.create_activity(:sign_in, provider: params[:provider],
                                     auth_token: user.auth_token)
      render json: @auth.user, serializer: Api::V2::AuthSerializer, root: :user, status: :ok
    else
      render json: { message: t('errors.invalie_params_oauth'), errors: @auth.error }, status: 401
    end
  end

  protected

  def handle_oauth2_error(ex)
    error_handler OAuth2Error.new(ex.code['message'], ex.code)
  end
end
