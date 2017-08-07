class Api::V2::ResetPasswordTokensController < ApiV2Controller
=begin
@api {post} /api/reset_password_token Post reset password token request
@apiVersion 2.0.0
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
    white_lists = %w(staging.commandp.com.cn
                     staging.commandp.com
                     commandp.com
                     commandp.com.cn
                     commandp.dev
                     127.0.0.1
                     localhost)
    url = params[:url]
    fail InvalidUrlError if url && !white_lists.any? { |host| URI(url).host == host }
    ResetPasswordMailerWorker.perform_async(user.id, url)
    render json: { massage: 'success', email: user.email }, status: :ok
  end

=begin
@api {put} /api/reset_password_token Update user password with reset token
@apiVersion 2.0.0
@apiGroup ResetPasswordToken
@apiName UpdatePassword
@apiParam {String} reset_password_token user's unencrypt reset_password_token
@apiParam {String} password password to update
@apiParam {String} password_confirmation password confirm
@apiSuccessExample {json} Response-Example:
{
  "user": {
    "user_id": 11,
    "auth_token": null,
    "email": "yoona.lin@commandp.com",
    "username": "yoona.lin",
    "role": "normal",
    "mobile": null,
    "avatar": {
      "thumb": "http://commandp.dev/assets/img_fbdefault.png?v=1439543228",
      "normal": "http://commandp.dev/assets/img_fbdefault.png?v=1439543228"
    },
    "links": {
      "orders": {
        "url": "http://commandp.dev/api/my/orders",
        "accept": "application/commandp.v1"
      },
      "works": {
        "url": "http://commandp.dev/api/my/works",
        "accept": "application/commandp.v1"
      }
    }
  }
}
=end
  def update
    attributes = params.permit(:reset_password_token, :password, :password_confirmation)
    user = User.reset_password_by_token(attributes)
    if user.errors.size == 0
      render json: user, serializer: Api::V2::AuthSerializer, root: :user, status: :ok
    else
      fail ActiveRecord::RecordInvalid, user
    end
  end
end
