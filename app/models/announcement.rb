# == Schema Information
#
# Table name: announcements
#
#  id         :integer          not null, primary key
#  message    :text
#  starts_at  :datetime
#  ends_at    :datetime
#  default    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class Announcement < ActiveRecord::Base
  translates :message, fallbacks_for_empty_translations: true
  globalize_accessors

  before_save :falsify_all_others
  before_validation :set_default
  validate :verify_at_least_one_default
  validates_presence_of :starts_at, :ends_at, :message, locale: :en

  scope :default, -> { where(default: true) }
  scope :available, ->(time = Time.zone.now) { where('starts_at <= ? AND ends_at >= ?', time, time).where(default: false) }
  scope :lists, ->(time = Time.zone.now) {
                    where("(starts_at <= ? AND ends_at >= ? AND \"default\" = 'f') OR (\"default\" = 't')", time, time) }

  private

  def falsify_all_others
    return unless default?
    Announcement.where.not(id: id).update_all(default: false)
  end

  def verify_at_least_one_default
    return unless default_changed?(from: true, to: false)
    errors.add(:default, :at_least_one)
  end

  def set_default
    return if Announcement.default.exists?
    self.default = true
  end
end
