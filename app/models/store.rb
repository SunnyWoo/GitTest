# == Schema Information
#
# Table name: stores
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  name                   :string(255)
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  title                  :string(255)
#  description            :text
#  avatar                 :string(255)
#  code                   :string(255)
#  slug                   :string(255)
#  tap_settings           :json
#  logo                   :string
#  store_footer_img       :string
#  contact_info           :hstore
#

class Store < ActiveRecord::Base
  store_accessor :contact_info, :contact_emails

  TAPS = %w(create shop).freeze
  serialize :tap_settings, Hashie::Mash.pg_json_serializer
  extend FriendlyId
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :standardized_works, as: :user
  has_many :components, class_name: 'StoreComponent'
  has_many :templates, class_name: 'ProductTemplate'
  accepts_nested_attributes_for :components, allow_destroy: true

  validates :password, format: {
    with:      /(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/,
    message:   'Password should be composed of [A-Z], [a-z], and [0-9]',
    multiline: true
  }, allow_blank: true
  validates :slug, uniqueness: true
  validate :validate_log_image_size

  mount_uploader :avatar, DesignerAvatarUploader
  mount_uploader :logo, StoreLogoUploader
  mount_uploader :store_footer_img, DefaultWithMetaUploader

  delegate :kv, :ticker, to: :components
  before_validation :generate_code
  after_commit :enqueue_generate_store_footer_img, if: proc { |s| s.previous_changes.key?(:logo) || s.previous_changes.key?(:slug) }

  friendly_id :name, use: [:slugged, :finders]

  def self.generate_code
    loop do
      code = [*'0'..'9', *'A'..'Z'].sample(4).join
      return code unless code == '0000' || exists?(code: code)
    end
  end

  def display_name
    "B2B2C商店: #{name}"
  end

  def enqueue_generate_store_footer_img
    return unless logo.present?
    GenerateStoreFooterImgWorker.perform_async(id)
  end

  def generate_store_footer_img
    return unless logo.present?
    update(store_footer_img: ImageService::StoreFooter.new(self).generate)
  end

  def url_qrcode_path
    tempfile = Tempfile.new(['store_url_qrcode', '.png'])
    RQRCode::QRCode.new(url).as_png(size: 100,
                                    border_modules: 0,
                                    file: tempfile.path)
    tempfile.path
  end

  def url
    tld_length = Region.china? ? 2 : 1
    Rails.application.routes.url_helpers.store_url(id: self,
                                                   host: Settings.host,
                                                   tld_length: tld_length,
                                                   subdomain: store_subdomain)
  end

  def store_subdomain
    case Rails.env
    when 'production_ready'
      'store-pr'
    when 'staging'
      'store-stg'
    else
      'store'
    end
  end

  private

  def generate_code
    self.code ||= self.class.generate_code
  end

  # logo size width and height need gt 100px, and image should be square
  def validate_log_image_size
    return unless logo.image_size.present?
    w, h = logo.image_size
    if (h < 100 || w < 100) || (h.to_f / w.to_f != 1)
      errors.add :base, 'Logo size width and height need gt 100px, and image should be square.'
    end
  end
end
