require 'spec_helper'

describe Api::V1::SiteSettingsController, type: :controller do
  context 'app_version' do
    it 'status 200' do
      get :app_version
      expect(response).to be_success
    end

    it 'retruns latest APP version' do
      get :app_version
      expect(response_json['iOS']).to eq(SiteSetting.by_key('iOSVersion'))
      expect(response_json['Android']).to eq(SiteSetting.by_key('AndroidVersion'))
    end
  end
end
