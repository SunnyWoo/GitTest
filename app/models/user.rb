# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  avatar                 :string(255)
#  role                   :integer
#  profile                :hstore
#  gender                 :integer
#  background             :string(255)
#  image_meta             :json
#  mobile                 :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  mobile_country_code    :string(16)
#

class User < ActiveRecord::Base
  include Searchable
  include Searchable::UserSearchable
  include Logcraft::Trackable
  include Logcraft::Tracker
  include RedirectHelper
  has_paper_trail

  store_accessor :profile, :name, :location, :migrate_to_user_id, :send_fresh,
                 :first_name, :last_name, :mobile_country_code, :birthday, :locale
  serialize :image_meta, Hashie::Mash.pg_json_serializer

  has_many :omniauths, as: :owner, dependent: :destroy
  has_many :works, as: :user
  has_many :layers, through: :works
  has_many :orders
  has_many :devices, dependent: :destroy
  has_many :address_infos, as: :billable, dependent: :destroy
  has_many :asset_package_collectings
  has_many :asset_packages, through: :asset_package_collectings
  has_many :auth_tokens
  has_one :wishlist

  mount_uploader :avatar, UserAvatarUploader
  mount_uploader :background, UserBackgroundUploader

  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :confirmable, :trackable, :validatable, :async,
         omniauth_providers: [:facebook, :twitter, :weibo, :google_oauth2, :qq, :wechat]

  validates :email, uniqueness: { allow_blank: true }
  validates :mobile, uniqueness: { allow_blank: true }

  enum role: [:normal, :designer, :guest, :die]
  enum gender: [:male, :female, :unspecified]

  before_create :set_role
  after_create :enqueue_post_to_mailgun_mailing_list
  after_save :send_coupon_for_the_fresh_china, if: :china_fresh?

  ROLE_TYPES = %w(normal designer guest).freeze
  UNRANSACKABLE_ATTRIBUTES = %w(encrypted_password reset_password_token reset_password_sent_at remember_created_at
                                updated_at avatar).freeze
  GUEST_EMAIL_PATTERN = /^guest(.*)@commandp/

  # 重写ransack方法, 该方法需要默认参数auth_object ＝ nil
  def self.ransackable_attributes(_auth_object = nil)
    (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end

  def self.random_email
    "guest_#{UUIDTools::UUID.timestamp_create}@commandp.me"
  end

  def password_required?
    super && omniauths.count == 0
  end

  def auth_token
    auth_tokens.last.try(:token)
  end

  def generate_token
    auth_tokens.create
  end

  def facebook
    @facebook ||= Koala::Facebook::API.new(facebook_oauth_token)
    block_given? ? yield(@facebook) : @facebook
  rescue Koala::Facebook::APIError => e
    logger.info e.to_s
    nil # or consider a custom null object
  rescue Koala::Facebook::AuthenticationError => e
    logger.info e.to_s
  end

  def friends_count
    facebook { |fb| fb.get_connection('me', 'friends').size }
  end

  def username
    return 'Guest' if guest? || die?
    name || facebook_username
  end

  %w( uid oauth_token username ).each do |attr|
    define_method "facebook_#{attr}" do
      omniauths.find_by(provider: 'facebook').try(:send, attr)
    end
  end

  def last_order
    orders.includes(:billing_info, :shipping_info).order('created_at DESC').first
  end

  def display_name
    username
  end

  def locale
    super || Region.default_locale
  end

  def publish_to_device(device_id, message)
    device = devices.find(device_id)
    begin
      res = AwsSns::PublishToDevice.new(device: device, message: message).execute
      if res.present?
        create_activity(:publish_notification_success, source: { channel: 'worker' }, message: message, device_id:
                        device_id, message_id: res[:message_id])
      end
    rescue => e
      create_activity(:publish_notification_error, source: { channel: 'worker' }, message: message, device_id:
                      device_id, res: e.message)
    end
  end

  def guest_to_user_from_access_token(access_token)
    resource_owner = ResourceOwner.from_access_token(access_token)
    guest_user = resource_owner.user if resource_owner
    GuestToUserService.migrate_data(guest_user, self) if guest_user.present?
  end

  class << self
    def new_guest
      user = User.new(role: :guest)
      user.password = Devise.friendly_token[0, 10]
      user.email = User.random_email
      user.skip_confirmation!
      user.save!
      user.generate_token
      user
    end

    # 如果使用者初次登入是fb，那麼該使用者資訊此時都是fb來的，之後使用者又改用google登入的話，
    # 那資訊就會轉而是google的，使用者又轉用fb登入時，使用者資訊依然會是google的，
    # 因為該fb的omniauth已被建立過所以會直接回傳omniauth.owner，而這owner(也就是user)
    # 的資訊保持著google登入時被建立的狀態。如果該使用者又改用twitter登入，那麼該使用者的資料就會被更新成twitter的
    def from_omniauth(auth, login_user = nil)
      omniauth = Omniauth.where(provider: auth.provider, uid: auth.uid.to_s).first_or_initialize
      omniauth.oauth_token = auth.credentials.token
      omniauth.oauth_secret = auth.credentials.secret
      if omniauth.owner.blank? # if this omniauth is a new record
        if login_user.present? # if user logged in
          login_user.email = auth.info.email # user is current user
          login_user.role = :normal
          user = login_user
        else
          email = auth.info.email || User.random_email
          user = User.where(email: email).first_or_initialize # find or create a new user with auth email
          if user.new_record?
            user.skip_confirmation!
            user.password = Devise.friendly_token[0, 10]
          end
        end
        # 各方omniauth提供內容各異的auth都交給OmniauthUserService去實做
        OmniauthUserService.new(auth, user, omniauth).execute # user is a user with omniauth record or not
      else
        omniauth.save!
        if login_user.present? && login_user.guest?
          GuestToUserService.migrate_data(login_user, omniauth.owner)
        end
      end
      omniauth.owner
    end
  end

  # 讓 pg 的 hstore 支援 ransack
  ransacker :name do |parent|
    Arel::Nodes::InfixOperation.new('->', parent.table[:profile], 'name')
  end

  def enqueue_post_to_mailgun_mailing_list
    return unless normal?
    return if email.match(User::GUEST_EMAIL_PATTERN)
    MailgunAddMailingListWorker.perform_async(email, 'all')
    MailgunAddMailingListWorker.perform_async(email, 'user')
    MailgunDeleteMailingListWorker.perform_async(email, 'bought')
  end

  def send_password_reset_token(url = nil)
    token, token_enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = token_enc
    self.reset_password_sent_at = Time.zone.now.utc
    save(validate: false)
    mail = UserMailer.send_password_reset(id, token, url)
    mail.deliver and Message.create(user: self, mail: mail)
    create_activity :send_password_reset, token: token, url: url ||= 'default'
    token
  end

  def send_confirmation_token(url = nil)
    token, token_enc = Devise.token_generator.generate(self.class, :confirmation_token)
    self.confirmation_token = token_enc
    self.confirmation_sent_at = Time.zone.now.utc
    save(validate: false)
    mail = UserMailer.send_confirmation(id, token, url)
    mail.deliver and Message.create(user: self, mail: mail)
    create_activity :send_confirmation_token, token: token, url: url ||= 'default'
    token
  end

  def send_coupon_for_the_fresh_china
    return if send_fresh
    CouponNoticeService.new(id).execute
  end

  def self.authentication_by_login(login)
    return User.find_for_database_authentication(email: login) if EmailValidator.valid?(login)
    User.find_for_database_authentication(mobile: login)
  end

  def send_confirmation_instructions
    super if normal?
  end

  def confirm!
    super
    if !email.match(User::GUEST_EMAIL_PATTERN) && confirmed?
      UserWelcomeMailWorker.perform_async(id)
    end
  end

  def send_welcome
    UserMailer.send_welcome(id).deliver
  end

  def code
    '0000'
  end

  def paid_orders_with_coupon(coupon_id)
    orders.user_was_paid.where(coupon_id: coupon_id)
  end

  def delayed_orders_with_coupon(coupon_id)
    orders.waiting_for_payment.where(payment: Order::DELAY_PAYMENTS, coupon_id: coupon_id)
  end

  def access_token(application_id = nil)
    application_id ||= Doorkeeper::Application.find_by(name: 'api').try(:id)
    Doorkeeper::AccessToken.find_or_create_by(
      application_id: application_id,
      resource_owner_id: id,
      scopes: 'public'
    ).token
  end

  private

  # overwrite to skip confirmable callback :generate_confirmation_token
  def confirmation_required?
    !confirmed? && !@skip_confirmation_notification
  end

  def set_role
    self.role = :normal if role.nil?
  end

  def china_fresh?
    Region.china? && normal?
  end
end
