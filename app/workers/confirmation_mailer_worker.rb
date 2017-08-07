class ConfirmationMailerWorker
  include Sidekiq::Worker

  def perform(user_id, url)
    user = User.find user_id
    user.send_confirmation_token(url)
  end
end
