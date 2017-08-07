# == Schema Information
#
# Table name: designers
#
#  id                     :integer          not null, primary key
#  username               :string(255)      default(""), not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  display_name           :string(255)
#  avatar                 :string(255)
#  description            :text
#  image_meta             :json
#  created_at             :datetime
#  updated_at             :datetime
#  code                   :string(255)
#

class Designer < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord
  include Logcraft::Trackable
  include Logcraft::Tracker
  include PreprocessImage

  serialize :image_meta, Hashie::Mash.pg_json_serializer

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :works, as: :user
  has_many :standardized_works, as: :user

  mount_uploader :avatar, DesignerAvatarUploader
  carrierwave_meta_composed :image_meta, :avatar
  preprocess_image :avatar, versions: %w(thumb s154)

  validates :username, :email, :code, uniqueness: true

  before_validation :generate_code

  scope :ordered, -> { order('display_name ASC') }

  def self.generate_code
    loop do
      code = [*'0'..'9', *'A'..'Z'].sample(4).join
      return code unless code == '0000' || exists?(code: code)
    end
  end

  def guest?
    false
  end

  def display_name
    super || username
  end

  private

  def generate_code
    self.code ||= self.class.generate_code
  end
end
