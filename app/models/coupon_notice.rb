# == Schema Information
#
# Table name: coupon_notices
#
#  id         :integer          not null, primary key
#  coupon_id  :integer
#  notice     :string(255)
#  available  :boolean
#  platform   :json
#  region     :json
#  created_at :datetime
#  updated_at :datetime
#

class CouponNotice < ActiveRecord::Base
  serialize :region, Hashie::Mash.pg_json_serializer
  serialize :platform, Hashie::Mash.pg_json_serializer
  belongs_to :coupon

  scope :available, -> { where(available: true) }
  scope :mobile_available, -> { available.where("platform ->> 'mobile' = :result", result: 'true') }
  scope :email_available, -> { available.where("platform ->> 'email' = :result", result: 'true') }
  scope :china, -> { where("region ->> 'china' = :result", result: 'true') }
  scope :global, -> { where("region ->> 'global' = :result", result: 'true') }

  validates :notice, presence: true
  validates :coupon_id, presence: true, uniqueness: true
  validate :render_notice_success
  before_save :check_platform, :check_region

  def self.platforms
    { mobile: false, email: false }
  end

  def self.regions
    { china: false, global: false }
  end

  def coupon_code
    @code ||= generate_coupon_code
  end

  def render_notice
    message = notice % { coupon_code: coupon_code }
    fail CouponMessageFormatError if notice == message
    message
  end

  private

  def generate_coupon_code
    coupon.create_unique_coupon_child.code
  end

  def render_notice_success
    message = notice % { coupon_code: coupon_code }
    errors.add(:notice, '正确格式为: text%{coupon_code}text') if notice == message
  end

  def check_platform
    default_platform_attrs = CouponNotice.platforms.stringify_keys
    self.platform = default_platform_attrs.merge(booleanize_hashs(platform))
  end

  def check_region
    default_region_attrs = CouponNotice.regions.stringify_keys
    self.region = default_region_attrs.merge(booleanize_hashs(region))
  end

  def booleanize_hashs(hash)
    hash.each { |k, v| hash[k] = v.to_b if v.respond_to?(:to_b) }
  end
end
