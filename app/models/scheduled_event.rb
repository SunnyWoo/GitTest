# == Schema Information
#
# Table name: scheduled_events
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  scheduled_at :datetime
#  executed     :boolean          default(FALSE)
#  extra_info   :json
#  created_at   :datetime
#  updated_at   :datetime
#

# ScheduledEvent: 可以事先將要運作的程式碼寫進 repo 裡，並透過 ScheduledEvent 管理
# ScheduledEventService 負責存放要執行的程式碼
class ScheduledEvent < ActiveRecord::Base
  validates :name, uniqueness: true

  validate :validate_implemented

  scope :available_to, ->(time) { where(executed: false).where('scheduled_at <= ?', time) }

  def self.trigger!
    now = Time.zone.now
    available_to(now).order(:scheduled_at).each do |event|
      ScheduledEventService.try(:send, event.name)
      event.update_attributes(executed: true)
    end
  end

  def implemented?
    ScheduledEventService.respond_to?(name)
  end

  private

  def validate_implemented
    errors.add(:name, "ScheduledEventService##{name} is not implemented yet!") unless implemented?
  end
end
