class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :require_no_authentication, if: -> { current_user.try(:guest?) }

  def new
    @user = User.new
    render template: '/devise/registrations/new'
  end

  def create
    login_user = user_signed_in? ? current_user : nil
    @user = register_user
    @user.logcraft_user = @user
    GuestToUserService.migrate_data(login_user, @user) if login_user.present?
    log_with_current_user @user
    @user.create_activity(:sign_up)
    redirect_to new_user_session_path, notice: I18n.t('devise.sessions.confirmation_notice')
  rescue ActiveRecord::RecordInvalid, MobileVerificationFailedError, ApplicationError => e
    @user = User.new(params[:user].to_h)
    @sign_up_errors = e.message
    render '/devise/registrations/new'
  end

  private

  def register_user
    if 'email' == params[:register_method]
      EmailAuthentication.new(params[:user]).user
    else
      service = MobileVerifyService.new(params[:user][:mobile])
      MobileSignUpService.new(service, params[:user].merge(code: params[:code])).user
    end
  end
end
