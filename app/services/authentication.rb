# class Authentication

#   def initialize(params)
#     @params = params
#     @omniauth = params[:omniauth]
#     @token = params[:auth_token]
#   end

#   def user
#     @user ||= @omniauth ? user_from_omniauth : user_with_password
#   end

#   def authenticated?
#     user.present?
#   end

#   def sign_in
#     user.generate_token
#     user.save!
#   end

#   private

#   def user_from_omniauth
#     service = Omniauth.where(@omniauth.slice(:provider, :uid)).first_or_initialize.tap do |omniauth|
#       omniauth.provider = @omniauth[:provider]
#       omniauth.uid = @omniauth[:uid]
#       omniauth.email = @omniauth[:info][:email]
#       omniauth.oauth_token =
#       if omniauth.new_record?
#         omniauth.build_owner(email: @omniauth[:info][:email])
#       end
#       omniauth.save!
#     end
#     service.owner
#   end

#   def user_with_password
#     user = User.find_for_database_authentication(email: @params[:email])
#     if user && user.valid_password?(@params[:password])
#       user
#     end
#   end

# end
