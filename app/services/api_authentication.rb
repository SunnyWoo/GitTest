class ApiAuthentication
  attr_reader :error

  def initialize(params)
    @provider = params[:provider]
    @uid = params[:uid]
    @email = params[:email]
    @token = params[:access_token]
    @user = nil
    @secret = params[:secret]
  end

  def user
    @user ||= verify_user
  end

  def authenticated?
    user.is_a? User
  end

  def sign_in
    user.generate_token
  end

  protected

  def verify_user
    user_hash = Omniauth.verify(@provider, @token, @secret)
    if %w(error errors).any? { |value| user_hash.key?(value) }
      @error = user_hash['error'] || user_hash['errors']
    else
      omniauth = Omniauth.find_or_initialize_by(provider: @provider, uid: @uid)
      omniauth.assign_attributes(oauth_token: @token, oauth_secret: @secret)
      if omniauth.new_record?
        Oauth2UserService.new(user_hash, omniauth, @email).execute
      else
        omniauth.tap(&:save!).owner
      end
    end
  rescue Net::HTTPServerException # oauth1 (twitter) will got this
    @error = 'Unauthorized'
  end
end
