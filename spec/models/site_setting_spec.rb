# == Schema Information
#
# Table name: site_settings
#
#  id          :integer          not null, primary key
#  key         :string(255)
#  value       :text
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe SiteSetting, type: :model do
  %i(key value).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  describe 'validations' do
    %i(key value).each do |attr|
      it { is_expected.to validate_presence_of(attr) }
    end

    it { is_expected.to validate_uniqueness_of(:key) }
  end

  describe '.by_key' do
    Given!(:site_setting) { create(:site_setting, key: 'abc', value: '12345') }
    Then { SiteSetting.by_key('abc') == '12345' }
    And { SiteSetting.by_key('not_found').blank? }
  end

  describe '.rn_ios_meta' do
    Given!(:version) { create(:site_setting, key: 'iOSRNVersion', value: '1.0.0') }
    Given!(:min_version) { create(:site_setting, key: 'iOSMinContainerVersion', value: '1.0.0') }
    Given!(:url) { create(:site_setting, key: 'iOSRNBundleURL', value: 'https://commandp.com') }
    Then do
      SiteSetting.rn_ios_meta == {
        'version' => '1.0.0',
        'minContainerVersion' => '1.0.0',
        'url' => {
          'url' => 'https://commandp.com',
          'isRelative' => false
        }
      }
    end
  end

  describe '.rn_android_meta' do
    Given!(:version) { create(:site_setting, key: 'AndroidRNVersion', value: '1.0.0') }
    Given!(:min_version) { create(:site_setting, key: 'AndroidMinContainerVersion', value: '1.0.0') }
    Given!(:url) { create(:site_setting, key: 'AndroidRNBundleURL', value: 'https://commandp.com') }
    Then do
      SiteSetting.rn_android_meta == {
        'version' => '1.0.0',
        'minContainerVersion' => '1.0.0',
        'url' => {
          'url' => 'https://commandp.com',
          'isRelative' => false
        }
      }
    end
  end
end
