require 'rails_helper'

RSpec.describe Api::V3::InfoController, :api_v3, type: :controller do
  describe '/info', signed_in: false do
    it 'returns api version' do
      get :show, access_token: access_token
      expect(response.status).to eq(200)
      expect(response.body).to eq({ 'info' => { 'api_version' => 'v3' } }.to_json)
    end
  end
end
