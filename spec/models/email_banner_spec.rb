# == Schema Information
#
# Table name: email_banners
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  file       :string(255)
#  starts_at  :datetime
#  ends_at    :datetime
#  is_default :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe EmailBanner do
  it 'FactoryGirl' do
    expect(build(:email_banner)).to be_valid
  end

  context 'available' do
    it 'when banner is not default' do
      banner_default = create(:email_banner, is_default: true)
      banner = create(:email_banner, starts_at: Date.yesterday, ends_at: Date.today + 2.days)
      expect(EmailBanner.available).to eq(banner)
    end

    it 'when banner is default' do
      banner = create(:email_banner, starts_at: Date.tomorrow, ends_at: Date.tomorrow + 2.days)
      default_banner = create(:email_banner, is_default: true)
      expect(EmailBanner.available).to eq(default_banner)
    end
  end
end
