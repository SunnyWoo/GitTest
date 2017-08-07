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

require 'rails_helper'

RSpec.describe MobileCampaign, type: :model do
  it 'FactoryGirl' do
    expect(build(:mobile_campaign)).to be_valid
  end

  let!(:mobile_campaign) { create(:mobile_campaign, is_enabled: true) }

  context '#scope' do
    before do
      create(:mobile_campaign, publish_at: Time.zone.now - 2.days, starts_at: Time.zone.yesterday,
                               ends_at: Time.zone.yesterday + 1.days, is_enabled: true)
      create(:mobile_campaign, publish_at: Time.zone.yesterday, starts_at: Time.zone.now,
                               ends_at: Time.zone.now + 1.days, is_enabled: true)
      create(:mobile_campaign, publish_at: Time.zone.tomorrow, starts_at: Time.zone.now + 1.days,
                               ends_at: Time.zone.now + 2.days, is_enabled: true)
    end

    it 'get publishable' do
      expect(MobileCampaign.count).to eq(4)
      expect(MobileCampaign.publishable.count).to eq(3)
    end

    it 'get available' do
      expect(MobileCampaign.available.count).to eq(2)
    end

    it 'check position' do
      expect(MobileCampaign.first.position).to eq(1)
      expect(MobileCampaign.last.position).to eq(4)
    end
  end

  context '#aasm campaign_type' do
    it 'get initial campaign_type' do
      expect(mobile_campaign.campaign_type).to eq('limited_time')
    end

    it 'campaign_type list' do
      expect(MobileCampaign.aasm(:campaign_type).states.map(&:name)).to eq([:limited_time, :limited_quantity])
    end
  end

  context 'validate' do
    it '#validates_publish_at' do
      expect { create(:mobile_campaign, publish_at: Time.zone.now, starts_at: Time.zone.now.yesterday) }.to raise_error
    end

    it '#validates_starts_at_and_ends_at' do
      expect { create(:mobile_campaign, starts_at: Time.zone.now, ends_at: Time.zone.now.yesterday) }.to raise_error
    end
  end
end
