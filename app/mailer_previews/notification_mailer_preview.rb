class NotificationMailerPreview
  def notify_download
    NotificationMailer.notify_download user_id, work_id
  end
end
