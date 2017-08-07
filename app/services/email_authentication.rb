class EmailAuthentication
  def initialize(params)
    @email = params[:email] || params[:login]
    @name = params[:name]
    @password = params[:password]
    @password_input = params[:password_input]
    @password_confirmation = params[:password_confirmation] if params[:password_confirmation]
    @skip_notification = params[:skip_notification]
    @user = nil
  end

  def user
    @user ||= case
              when @password_input
                find_user
              else
                create_user
              end
  end

  def authenticated?
    user.present?
  end

  def sign_in
    user.generate_token
  end

  protected

  def find_user
    User::SignIn.new(email: @email, password_input: @password_input).save!
  end

  def create_user
    User::SignUp.new(email: @email,
                     name: @name,
                     password: @password,
                     password_confirmation: @password_confirmation,
                     locale: I18n.locale,
                     skip_notification: @skip_notification).save!
  end
end
