=begin
@apiDefine AdminOmniauthResponse
@apiSuccessExample {json} Success-Response:
  HTTP/1.1 200 OK
  {
    "omniauth": {
      "provider": "facebook",
      "uid": "uid-1",
      "oauth_token": "oauth-1",
      "owner_id": 1,
      "owner_type": "User"
    }
  }
=end
class Api::V2::Admin::OmniauthsController < ApiV2Controller
  before_action :find_omniauth, only: [:show, :destroy]

=begin
@api {get} /api/admin/omniauths/:token Retrieve omniauth
@apiUse AdminOmniauthResponse
@apiVersion 2.0.0
@apiGroup AdminOmniauths
@apiPermission admin
@apiName AdminShowOmniauth
@apiParamExample {json} Request-Example
  GET /api/admin/omniauths/d9ee8acd0d2b5f0e1b951f662eb9e1aa
=end
  def show
  end

=begin
@api {delete} /api/admin/omniauths/:token Delete omniauth
@apiVersion 2.0.0
@apiGroup AdminOmniauths
@apiPermission admin
@apiName AdminDeleteOmniauth
@apiParamExample {json} Request-Example
  DELETE /api/admin/omniauths/d9ee8acd0d2b5f0e1b951f662eb9e1aa
@apiSuccessExample {json} Success-Response:
  HTTP/1.1 200 OK
  {
    msg: "Omniauth destroyed!"
  }
=end
  def destroy
    @omniauth.destroy
    render json: { msg: 'Omniauth destroyed!' }, status: :ok
  end

  protected

  def find_omniauth
    @omniauth = Omniauth.find_by!(oauth_token: params[:id])
  end
end
