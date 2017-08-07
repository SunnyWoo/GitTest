# == Schema Information
#
# Table name: mobile_campaigns
#
#  id            :integer          not null, primary key
#  kv            :string(255)
#  title         :string(255)
#  desc_short    :string(255)
#  ticker        :string(255)
#  campaign_type :string(255)
#  publish_at    :datetime
#  starts_at     :datetime
#  ends_at       :datetime
#  is_enabled    :boolean          default(FALSE)
#  position      :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class MobileCampaign < ActiveRecord::Base
  include ActsAsIsEnabled
  acts_as_list

  validates :publish_at, :starts_at, :ends_at, presence: true
  validate :validates_publish_at
  validate :validates_starts_at_and_ends_at

  default_scope { order('position ASC') }
  scope :publishable, -> { enabled.where('publish_at <= :now', now: Time.zone.now) }
  scope :available, -> { enabled.where('starts_at <= :now and ends_at >= :now', now: Time.zone.now) }

  translates :kv, :title, :desc_short, :ticker
  globalize_accessors
  accepts_nested_attributes_for :translations
  Translation.mount_uploader :kv, DefaultWithMetaUploader

  include AASM
  aasm(:campaign_type) do
    state :limited_time, initial: true
    state :limited_quantity
  end

  protected

  def validates_publish_at
    return unless publish_at > starts_at
    errors.add(:publish_at, :invalid_publish_at_lt_starts_at)
  end

  def validates_starts_at_and_ends_at
    return unless starts_at > ends_at
    errors.add(:starts_at, :invalid_starts_at_lt_end_at)
  end
end
