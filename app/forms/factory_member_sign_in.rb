class FactoryMemberSignIn
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :code, :username, :password

  validates :code, :username, :password, presence: true
  validate :check_factory_code
  validate :check_password

  def user
    @user ||= FactoryMember.find_by!(username: username)
  end

  def save!
    if valid?
      user
    else
      fail ActiveRecord::RecordInvalid, self
    end
  end

  private

  def check_password
    return if user.valid_password?(password)
    errors.add(:base, I18n.t('errors.invalid_password_input'))
  end

  def check_factory_code
    return if user.factory.code == code
    errors.add(:base, 'Account does not exist')
  end
end
