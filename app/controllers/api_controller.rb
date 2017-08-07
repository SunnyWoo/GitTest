class ApiController < ApplicationController
  include LogcraftForApi
  include SharedApiMethods

  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_error

  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate
  skip_before_action :cn_redirect_to

  before_action :log_request

  def authenticate_required!
    if params[:auth_token].present?
      @current_user ||= AuthToken.authenticate(params[:auth_token])
      render json: { status: 'error', message: I18n.t(:invalid_token) }, status: 401 unless current_user
    else
      render json: { status: 'error', message: I18n.t(:token_required) } unless params[:auth_token].present?
    end
  end

  helper_method :api_permitted_params

  protected

  def record_invalid_error
    render json: { message: I18n.t(:record_invalid_error) }, status: 400
  end

  def not_found_error
    render json: { message: I18n.t(:not_found_error) }, status: 404
  end
end
