require 'spec_helper'

describe ApiController, type: :controller do
  describe 'Get /api/rn_version' do
    it 'return rn_version info' do
      get :rn_version
      expect(response.code).to eq('200')
      expect(response_json).to eq(SiteSetting.rn_ios_meta)
    end
  end
end
