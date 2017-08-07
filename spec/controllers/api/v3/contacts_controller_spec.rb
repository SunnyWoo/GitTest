require 'spec_helper'

describe Api::V3::ContactsController, :api_v3, type: :controller do
  describe 'POST /contacts', signed_in: false do
    it 'creates contacts' do
      contents = '我要訂１０個手機殼。'
      post :create, access_token: access_token, contents: contents
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq('success')
    end
  end
end
