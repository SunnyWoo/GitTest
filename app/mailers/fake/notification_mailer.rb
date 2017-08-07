class Fake::NotificationMailer < NotificationMailer
  def notify_download(email = 'to@example.org', locale = 'en')
    @user = FakeUser.new
    @work = FakeWork.new
    I18n.with_locale(locale) do
      mail to: email, subject: I18n.t('email.notification.notify_download.subject'), template_path: 'notification_mailer', template_name: 'notify_download'
    end
  end
end

class FakeUser 
  def username
    "Maile Test Name"
  end
end

class FakeWork
  def cover_image_url(type)
    'http://commandp.dev/uploads/work/cover_image/1/print_test.jpg'
  end
end