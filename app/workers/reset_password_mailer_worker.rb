class ResetPasswordMailerWorker
  include Sidekiq::Worker

  def perform(user_id, url)
    user = User.find user_id
    user.send_password_reset_token(url)
  end
end
