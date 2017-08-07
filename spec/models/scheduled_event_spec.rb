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

require 'rails_helper'

RSpec.describe ScheduledEvent, type: :model do
  Given!(:change_event) { ScheduledEvent.create!(name: 'change_price_22_9', scheduled_at: Time.zone.parse('2016-02-29 00:00')) }

  describe '.available_to' do
    Given!(:backup_event) { ScheduledEvent.create!(name: 'backup_price_22_9', scheduled_at: Time.zone.parse('2016-03-01 00:00')) }
    Then { ScheduledEvent.available_to(Time.zone.parse('2016-02-29 00:05')) == [change_event] }
    And { ScheduledEvent.available_to(Time.zone.parse('2016-04-01 00:00')) == [change_event, backup_event] }
  end

  describe '.trigger!' do
    before { Timecop.freeze(Time.zone.parse('2016-02-29 00:05')) }
    before { expect(ScheduledEventService).to receive(:change_price_22_9) }
    Given!(:backup_event) { ScheduledEvent.create!(name: 'backup_price_22_9', scheduled_at: Time.zone.parse('2016-03-01 00:00')) }
    When { ScheduledEvent.trigger! }
    Then { change_event.reload.executed? }
    And { backup_event.reload.executed? == false }
    after { Timecop.return }
  end

  describe '#implemented?' do
    Given(:event) { ScheduledEvent.new(name: 'random999', scheduled_at: Time.zone.now) }
    Then { change_event.implemented? }
    And { event.implemented? == false }
    And { event.valid? == false }
  end
end
