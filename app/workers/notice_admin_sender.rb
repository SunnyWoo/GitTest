class NoticeAdminSender
  include Sidekiq::Worker

  def perform(emails, title, contents)
    contents = contents.gsub("\\n", "\n").gsub("\\r", "\r")
    ApplicationMailer.notice_admin(emails, title, contents).deliver
  end
end
