class NotificationPushToDeviceWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(notification_id, device_id)
    notification = Notification.find(notification_id)
    notification.publish_to_device(device_id)
  end
end
