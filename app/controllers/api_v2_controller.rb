class ApiV2Controller < ApplicationController
  include LogcraftForApi
  include SharedApiMethods

  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid_error

  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate
  skip_before_action :cn_redirect_to

  before_action :log_request

  helper_method :api_permitted_params

  private

  def authenticate_required!
    raise MissingTokenError if params[:auth_token].blank?
    @current_user ||= AuthToken.authenticate(params[:auth_token])
  rescue ActiveRecord::RecordNotFound
    raise AuthenticationFailedError
  end
end
