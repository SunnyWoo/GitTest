class Print::SessionsController < Devise::SessionsController
  skip_before_action :require_no_authentication, only: [:new, :create]
  before_action :authenticate_factory_member!, only: [:destroy]

  def new
    @sign_in_factory_member = FactoryMemberSignIn.new
    redirect_to print_print_path if current_factory_member
  end

  def create
    factory_member = FactoryMemberSignIn.new(code: login_params[:code],
                                             username: login_params[:username],
                                             password: login_params[:password]).save!

    sign_in factory_member
    redirect_to print_print_path, notice: I18n.t('devise.sessions.signed_in')
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => _e
    flash[:error] = 'Account does not exist'
    redirect_to new_factory_member_session_path
  end

  def destroy
    sign_out current_factory_member
    redirect_to new_factory_member_session_path
  end

  private

  def login_params
    params.require(:factory_member_sign_in).permit(:code, :username, :password)
  end
end
