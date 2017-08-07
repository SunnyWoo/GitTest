class Api::V3::ResetPasswordTokensController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {post} /api/reset_password_token Post reset password token request
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup ResetPasswordToken
@apiName PostResetPasswordToken
@apiParam {String} email User's email when he signed up
@apiParam {String} [url=nil] to redirect edit password page if provided, and which must be legal
@apiSuccessExample {json} Response-Example:
{
  "massage": "success",
  "email": "yoona.lin@commandp.com"
}
=end
  def create
    user = User.find_by!(email: params[:email])
    url = params[:url]
    fail InvalidUrlError if url && URI(url).host != URI(doorkeeper_token.application.redirect_uri).host
    ResetPasswordMailerWorker.perform_async(user.id, url)
    render json: { massage: 'success', email: user.email }, status: :ok
  end

=begin
@api {put} /api/reset_password_token Update user password with reset token
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup ResetPasswordToken
@apiName UpdatePassword
@apiParam {String} reset_password_token user's unencrypt reset_password_token
@apiParam {String} password password to update
@apiParam {String} password_confirmation password confirm
@apiSuccessExample {json} Response-Example:
{
  "user": {
    "id": 178,
    "email": "iwannagohome@commandp.com",
    "username": null,
    "first_name": null,
    "last_name": null,
    "mobile": null,
    "mobile_country_code": null,
    "avatar": {
      "use_default_image": true,
      "thumb": "http://commandp.dev/assets/img_fbdefault.png?v=1454412105",
      "normal": "http://commandp.dev/assets/img_fbdefault.png?v=1454412105"
    },
    "birthday": null
  }
}
=end
  def update
    attributes = params.permit(:reset_password_token, :password, :password_confirmation)
    user = User.reset_password_by_token(attributes)
    if user.errors.size == 0
      render json: user, status: :ok, serializer: UserSerializer
    else
      fail ActiveRecord::RecordInvalid.new user
    end
  end
end
