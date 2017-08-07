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

require 'rails_helper'

RSpec.describe Announcement, type: :model do
  it 'FactoryGirl' do
    expect(build(:announcement)).to be_valid
  end

  describe '#falsify_all_others' do
    it 'trigger callback' do
      new_announcement = build(:announcement, default: true)
      expect(new_announcement).to receive(:falsify_all_others)
      new_announcement.save
    end

    it 'falsify_all_others' do
      announcement = create(:announcement, default: true)
      expect { create(:announcement, default: true) }.to change { announcement.reload.default? }.from(true).to(false)
      expect(Announcement.last.default?).to eq(true)
    end
  end

  describe '#verify_at_least_one_default' do
    it 'set current to default when there is no default in DB' do
      announcement = Announcement.new(message: '12',
                                      starts_at: Time.zone.now,
                                      ends_at: Time.zone.now,
                                      default: false)
      announcement.save
      expect(announcement.default).to eq true
    end

    it 'failed when update self from default to not default' do
      announcement = create(:announcement, default: true)
      announcement.default = false
      expect(announcement).not_to be_valid
    end
  end

  context '#lists' do
    it 'return lists' do
      create(:announcement, default: true)
      create(:announcement, default: false)
      create(:announcement, default: false, starts_at: Date.today, ends_at: Date.tomorrow)
      expect(Announcement.lists.count).to eq(2)
    end
  end
end
