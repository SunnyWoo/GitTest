class Api::V2::PasswordController < ApiV2Controller
before_action :authenticate_required!, only: :update
=begin
@api {put} /api/password Update user password without
@apiVersion 2.0.0
@apiGroup Password
@apiName UpdatePasswordWithoutToken
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
    if current_user.reset_password!(params[:password], params[:password_confirmation])
      render json: current_user, serializer: Api::V2::AuthSerializer, root: :user, status: :ok
    else
      fail ActiveRecord::RecordInvalid, current_user
    end
  end
end
