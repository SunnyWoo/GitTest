class NotificationMailer < ApplicationMailer
  def notify_download(user_id, work_id)
    @user = User.find(user_id)
    @work = Work.find(work_id)
    mail to: @user.email, subject: '[commandp] 已經可以下載你的新作品'
  end
end
