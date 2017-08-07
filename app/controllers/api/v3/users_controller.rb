class Api::V3::UsersController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :check_user, only: [:bind_mobile]
=begin
@api {post} /api/users/:id Get the public user info, e.g. email should not be public
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Users
@apiName GetPublicUserinfo
@apiParam {Integer} id user id
@apiUse V3_UserResponse
=end
  def show
    @user = User.find(params[:id])
  end

=begin
@api {post} /api/bind_mobile 綁定手機
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Users
@apiName BindMobile
@apiParam {String} mobile   Mobile number, ex: '18516109323'
@apiParam {String} code     Code for verify, ex: '134513'
@apiUse V3_UserResponse
=end
  def bind_mobile
    service = MobileVerifyService.new(params[:mobile])
    fail MobileVerificationFailedError unless service.verify(params[:code])
    @user = current_user
    @user.update_attributes!(mobile: service.mobile)
    render :show
  end
end
