class UserNotificationPublisher
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id, device_id, message)
    user = User.find(user_id)
    user.publish_to_device(device_id, message)
  end
end
