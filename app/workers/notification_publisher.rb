class NotificationPublisher
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(notification_id)
    @notification = Notification.find(notification_id)
    @notification.publish
  end
end
