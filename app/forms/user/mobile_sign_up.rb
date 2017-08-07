class User::MobileSignUp
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :mobile, :password, :confirmed_at

  validates :password, confirmation: true
  validates_presence_of :password, :password_confirmation

  def save!
    if valid?
      user = User.new(
        email: User.random_email,
        role: :normal, password: password, mobile: mobile,
        confirmed_at: confirmed_at
      )
      user if user.save!
    else
      fail ActiveRecord::RecordInvalid.new self
    end
  end
end
