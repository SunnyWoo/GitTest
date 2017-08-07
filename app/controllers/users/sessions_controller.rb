class Users::SessionsController < Devise::SessionsController
  skip_before_action :require_no_authentication, only: [:new, :create]
  before_action :authenticate_user!, only: [:destroy]

  def new
    @sign_in_user = User::SignIn.new
    redirect_to root_path if current_user && current_user.normal?
  end

  def create
    do_login_user(verified_user)
    redirect_to root_path, notice: I18n.t('devise.sessions.signed_in')
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e
    flash[:error] = e.message
    redirect_to new_user_session_path
  end

  def destroy
    user = current_user
    log_with_current_user user
    user.create_activity(:sign_out)
    sign_out current_user
    clean_cookies_access_token
    redirect_to path
  end

  protected

  def path
    session[:return_to] || root_path
  end

  private

  def login_by_email?
    EmailValidator.valid?(params[:user_sign_in][:login])
  end

  def verified_user
    auth_class = login_by_email? ? EmailAuthentication : MobileAuthService
    auth_class.new(params[:user_sign_in]).user
  end

  def do_login_user(user)
    login_user = user_signed_in? ? current_user : nil
    GuestToUserService.migrate_data(login_user, user) if login_user.present?
    user.logcraft_user = user
    log_with_current_user user
    user.create_activity(:sign_in)
    sign_in user
  end
end
