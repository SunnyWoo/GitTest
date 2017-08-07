require 'spec_helper'

describe Api::V3::SiteSettingsController, :api_v3, type: :controller do
  context '#app_version', signed_in: false do
    Given!(:ios_app) { create :site_setting, key: 'iOSVersion' }
    Given!(:android_app) { create :site_setting, key: 'AndroidVersion' }
    context 'returns ok when everthins is right' do
      When { get :app_version, access_token: access_token }
      Then { response.status == 200 }
      And { response_json['iOS'] == SiteSetting.by_key('iOSVersion') }
      And { response_json['Android'] == SiteSetting.by_key('AndroidVersion') }
      And { response_json['RN_iOS'] == SiteSetting.rn_ios_meta }
      And { response_json['RN_Android'] == SiteSetting.rn_android_meta }
    end

    context 'returns the latest version' do
      before { ios_app.update value: 'The Force Awakens' }
      When { get :app_version, access_token }
      Then { response_json['iOS'] == 'The Force Awakens' }
    end
  end
end
