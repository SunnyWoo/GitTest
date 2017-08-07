class Api::V3::SessionsController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :check_user, only: %w(destroy)

=begin
@api {delete} /api/sign_out Normal User Sign Out
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Sessions
@apiName UserSignOut
@apiParam {access_token} token that logs in
@apiSuccessExample {json} Response-Example:
 {
  "user": {
    "id": 1,
    "email": "ooxx@hotmail.com",
    "username": "ooxx",
    "first_name": oo,
    "last_name": xx,
    "mobile": null,
    "mobile_country_code": null,
    "avatar": {
      "use_default_image": false,
      "thumb": "http://commandp.dev/uploads/user/avatar/1/03b1b5619f5b.jpg?v=1446092985",
      "normal": "http://commandp.dev/uploads/user/avatar/1/03b11890f29f5b.jpg?v=1446092985"
    },
    "birthday": null
  }
}
=end

  def destroy
    if current_user.guest?
      fail CurrentUserRequiredError
    else
      @user = current_user
      doorkeeper_token.update!(revoked_at: Time.zone.now)
      render 'api/v3/profiles/show'
    end
  end
end
