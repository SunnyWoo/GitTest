class Api::V3::PasswordController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :check_user
=begin
@api {put} /api/password Update user password without reset_password_token
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Password
@apiName UpdatePasswordWithoutToken
@apiParam {String} password password to update
@apiParam {String} password_confirmation password confirm
@apiSuccessExample {json} Response-Example:
{
  "user": {
    "id": 1,
    "email": "terrorer9999@hotmail.com",
    "username": "",
    "first_name": "Chen",
    "last_name": "Noel",
    "mobile": null,
    "mobile_country_code": "",
    "avatar": {
      "use_default_image": false,
      "thumb": "http://commandp.dev/uploads/user/avatar/1/9f5b.jpg?v=1454409519",
      "normal": "http://commandp.dev/uploads/user/avatar/1/0f29f5b.jpg?v=1454409519"
    },
    "birthday": "2000-10-10"
  }
}
=end
  def update
    if current_user.reset_password!(params[:password], params[:password_confirmation])
      render json: current_user, status: :ok, serializer: UserSerializer
    else
      fail ActiveRecord::RecordInvalid, current_user
    end
  end
end
