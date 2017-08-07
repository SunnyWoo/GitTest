class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include ErrorHandling
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid_error
  skip_before_filter :authenticate_user!, :verify_authenticity_token

  def all
    login_user = user_signed_in? ? current_user : nil
    user = User.from_omniauth(env["omniauth.auth"], login_user)
    if user
      log_with_current_user user
      user.logcraft_user = user
      user.create_activity(:sign_in, provider: env["omniauth.auth"].provider)
      write_access_token_to_cookie(user)
      sign_in_and_redirect user, event: :authentication, notice: I18n.t('devise.sessions.signed_in')
    else
      redirect_to new_user_registration_url
    end
  end

  alias_method :facebook, :all
  alias_method :twitter, :all
  alias_method :weibo, :all
  alias_method :google_oauth2, :all
  alias_method :qq, :all
end
