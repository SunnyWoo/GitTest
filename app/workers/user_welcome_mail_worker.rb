class UserWelcomeMailWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    user.send_welcome
  end
end
