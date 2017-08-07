class User::SignIn
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :email, :password_input, :login

  validates :password_input, :email, presence: true
  validate :check_password
  validate :check_confirmed

  def user
    @user ||= User.find_by!(email: email)
  rescue ActiveRecord::RecordNotFound
    fail UserSignInError
  end

  def save!
    if valid?
      user
    else
      fail ActiveRecord::RecordInvalid.new self
    end
  end

  protected

  def check_password
    return if user.valid_password?(password_input)
    errors.add(:base, I18n.t('errors.invalid_password_input'))
  end

  def check_confirmed
    errors.add(:base, I18n.t('errors.email_unconfirmed')) unless user.confirmed?
  end
end
