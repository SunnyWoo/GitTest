class UserMailerPreview
  def send_password_reset
    UserMailer.send_password_reset(user.id, 'xxxxx', nil)
  end

  def send_confirmation
    UserMailer.send_confirmation(user.id, 'xxxxx', nil)
  end

  def send_welcome
    UserMailer.send_welcome(user.id)
  end

  private

  def user
    user = User.find_by(id: @id) ||User.normal.first
    user.update locale: I18n.locale
    user
  end
end
