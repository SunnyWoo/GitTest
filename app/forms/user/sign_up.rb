class User::SignUp
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :email, :name, :password, :locale, :skip_notification

  validates :password, confirmation: true
  validates_presence_of :email, :password, :password_confirmation
  validate :check_email_unique

  def save!
    if valid?
      user = User.new(email: email, name: name, password: password, locale: locale || 'en')
      user.skip_confirmation_notification! if skip_notification.to_b
      user if user.save!
    else
      raise ActiveRecord::RecordInvalid.new self
    end
  end

  protected

  def check_email_unique
    if User.exists? email: email
      errors.add(:email, I18n.t('errors.email_already_exists'))
    end
  end
end
