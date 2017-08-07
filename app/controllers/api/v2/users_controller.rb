=begin
@apiDefine UserResponse
@apiSuccessExample {json} Success-Response:
  {
    "user": {
        "id": 1,
        "email": "user1@commandp.me",
        "username": "User Name",
        "first_name": "Carmel",
        "last_name": "Green",
        "mobile": 0910123456,
        "mobile_country_code": "TW",
        "avatar": {
            "use_default_image": true,
            "thumb": "/assets/img_fbdefault.png?v=1440484864",
            "normal": "/assets/img_fbdefault.png?v=1440484864"
        },
        "birthday": "2000-10-10"
    }
  }
=end
class Api::V2::UsersController < ApiV2Controller
  before_action :authenticate_required!

=begin
@api {get} /api/me 登入者資訊
@apiUse NeedAuth
@apiUse UserResponse
@apiGroup User
@apiName GetUser
@apiVersion 2.0.0
=end
  def show
    render json: current_user
    fresh_when(etag: current_user, last_modified: current_user.updated_at)
  end

=begin
@api {post} /api/merge_user Merge user
@apiDescription 請小心使用這個 API
  使用時機：使用者使用第三方登入後想要綁定已有的帳號
@apiUse NeedAuth
@apiUse AuthSuccess
@apiGroup User
@apiName MergeUser
@apiVersion 2.0.0
@apiParam {String} to_user_token Target user to merge to
@apiParamExample {json} Request-Example:
  {
    "auth_token": "from_user_auth_token",
    "to_user_token": "to_user_auth_token"
  }
=end
  def merge
    to_user = AuthToken.authenticate(params[:to_user_token])
    MergeUserService.migrate_data(current_user, to_user)
    render json: to_user.reload, serializer: Api::V2::AuthSerializer, root: :user, status: :ok
  end

=begin
@api {post} /api/bind_mobile 綁定手機
@apiUse NeedAuth
@apiUse UserResponse
@apiGroup User
@apiName BindUserMobile
@apiVersion 2.0.0
@apiParam {String} mobile   Mobile number, ex: '18516109323'
@apiParam {String} code     Code for verify, ex: '134513'
@apiParamExample {json} Request-Example:
  {
    "auth_token": "a_valid_token",
    "mobile": "18516109323",
    "code": "134513",
  }
=end
  def bind_mobile
    @service = MobileVerifyService.new(params[:mobile])
    fail MobileVerificationFailedError unless @service.verify(params[:code])
    current_user.update_attributes!(mobile: @service.mobile)
    render json: current_user, status: :ok
  end
end
