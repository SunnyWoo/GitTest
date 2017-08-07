class Api::V1::AuthController < ApiController
  include MigrateGuestToUserHelper
  before_action :authenticate_required!, only: [:destroy]

  # User Sign In
  #
  # Url : /api/sign_in
  #
  #     ＊若要轉換 Guest user to User 需要帶入 old_auth_token
  #
  # RESTful : POST
  #
  # Return Example
  #   {
  #     "user_id": 1,
  #     "auth_token": "40a2253a34c2a03315a352e9d16d92ec",
  #     "role": "normal",
  #     "links": [
  #       {
  #         "role": "orders",
  #         "url": "http://commandp.dev/api/my/orders?locale=zh-TW",
  #         "header": "commandp.v1"
  #       },{
  #         "role": "works",
  #         "url": "http://commandp.dev/api/my/works?locale=zh-TW",
  #         "header": "commandp.v1"
  #       }
  #      ]
  #   }
  #
  # @param request provider [String] the provider type, `facebook`
  # @param request uid [Integer] user_id
  # @param request access_token [String] user access_token
  # @param request email [String] user email
  # @param old_auth_token [String] old auth token
  #
  # @return [JSON] status 200

  def create
    @auth = ApiAuthentication.new(params)
    if @auth.authenticated?
      @auth.sign_in
      sign_in :user, @auth.user
      user = @auth.user
      migrate_guest_to_user(params[:old_auth_token], user) if params[:old_auth_token].present?
      log_with_current_user user
      user.logcraft_user = user
      user.create_activity(:sign_in, provider: params[:provider],
                                     auth_token: user.auth_token)
      render json: @auth, serializer: AuthSerializer, meta: 'success', meta_key: 'status', root: false
    else
      render json: { message: @auth.error }, status: 401
    end
  rescue OAuth2::Error => e
    render json: { status: 'error', message: e.message }, status: 401
  end

  # User Sign Out
  #
  # Url : /api/sign_out
  #
  # RESTful : DELETE
  #
  # Return Example
  #   {
  #     "status"=>"success",
  #     "message"=>"Sign out success"
  #   }
  #
  # @param request access_token [String] user access_token
  #
  # @return [JSON] status 200

  def destroy
    auth_sign_out
    render json: { status: 'success', message: 'Sign out success' }
  end

  protected

  def auth_sign_out
    current_user.auth_tokens.find_by(token: params[:auth_token]).destroy
    log_with_current_user current_user
    current_user.create_activity(:sign_out, auth_token: params[:auth_token])
    sign_out current_user
  end
end
