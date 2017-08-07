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

class SiteSetting < ActiveRecord::Base
  strip_attributes only: %i(key value)
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  class << self
    def by_key(key)
      SiteSetting.find_by(key: key).try(:value)
    end

    # 目前只使用于key： ShippingFeeSwitch
    def enabled?(key)
      by_key(key) == 'true'
    end

    def rn_ios_meta
      {
        version: by_key('iOSRNVersion'),
        minContainerVersion: by_key('iOSMinContainerVersion'),
        url: {
          url: by_key('iOSRNBundleURL'),
          isRelative: false
        }
      }.as_json
    end

    def rn_android_meta
      {
        version: by_key('AndroidRNVersion'),
        minContainerVersion: by_key('AndroidMinContainerVersion'),
        url: {
          url: by_key('AndroidRNBundleURL'),
          isRelative: false
        }
      }.as_json
    end

    def b2b2c_marketing_mails
      email = by_key('b2b2c_marketing_mails')
      return %w(reports@commandp.com) if email.blank?
      email.delete(' ').split(',')
    end
  end
end
