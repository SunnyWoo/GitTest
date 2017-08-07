class DeviseMailerPreview
  def confirmation_instructions
    DeviseMailer.confirmation_instructions user, user.confirmation_token
  end

  def reset_password_instructions
    token = @token || 'xxxx'
    DeviseMailer.reset_password_instructions(user, token)
  end

  private

  def user
    user = User.find_by(id: @id) ||User.guest.first
    user.update locale: I18n.locale
    user
  end
end
