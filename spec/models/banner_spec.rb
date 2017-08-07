# == Schema Information
#
# Table name: banners
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  image      :string(255)
#  image_meta :text
#  begin_on   :date
#  end_on     :date
#  countries  :string(255)      default([]), is an Array
#  created_at :datetime
#  updated_at :datetime
#  deeplink   :string(255)
#  platforms  :string(255)      default([]), is an Array
#  url        :string(255)
#

require 'rails_helper'

RSpec.describe Banner, type: :model do
  it 'FactoryGirl' do
    expect( build(:banner) ).to be_valid
  end
  it { should allow_value(['iOS']).for(:platforms) }
  it { should allow_value(['Android']).for(:platforms) }
  it { should allow_value(['iOS', 'Android']).for(:platforms) }
  it { should allow_value('https://www.taishinbank.com.tw/TS/TS02/TS0203/TS020303/TS02030301/index.htm').for(:url)}
  it { should_not allow_value([]).for(:platforms) }
  it { should_not allow_value(['Windows Phone']).for(:platforms) }
  it { should_not allow_value(['汽車貸款 林小姐']).for(:url) }

  context "validate either_url_or_deeplink" do
    let(:banner){ create :banner }
    it "should be valid when only deeplink provided" do
      banner.deeplink = "You\'ve got me!"
      expect(banner).to be_valid
    end

    it "should be valid when only url provided" do
      banner.url = "http://commandp.dev"
      expect(banner).to be_valid
    end

    it "should not be valid when both deeplink and url provided" do
      banner.deeplink = "You\'ve got me!"
      banner.url = "http://commandp.dev"
      expect(banner).not_to be_valid
    end
  end
end
