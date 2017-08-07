class MobileAuthService
  def initialize(params)
    @mobile = params[:mobile] || params[:login]
    @password_input = params[:password_input]
  end

  def user
    find_user
    fail AuthenticationFailedError unless @user.valid_password?(@password_input)
    @user
  end

  def find_user
    @user = User.find_by!(mobile: @mobile)
  rescue ActiveRecord::RecordNotFound
    fail UserSignInError
  end
end
