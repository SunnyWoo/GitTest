require 'spec_helper'

describe Api::V1::My::DevicesController, :vcr, type: :controller do
  before { @request.env.merge! api_header(1) }

  let(:user) { create(:user) }
  let!(:device) { create(:device, user: user) }

  context 'index' do
    it 'status 200' do
      get :index, auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response_json.size).not_to eq(0)
    end
    it 'miss auth_token' do
      get :index, {}
      expect(response_json['status']).to eq('error')
      expect(response_json['message']).to match('auth_token')
    end
  end

  context 'create' do
    it 'status 201' do
      post :create,         auth_token: user.auth_token,
                            token: 'xxxx',
                            os_version: 'iOS99',
                            device_type: 'iOS',
                            country_code: 'TW',
                            timezone: 'Taipei'
      expect(response.status).to eq(201)
      expect(response.body).not_to be nil
    end
  end

  context 'update' do
    it 'status 200' do
      put :update,         id: device.id,
                           auth_token: user.auth_token,
                           token: 'update token',
                           os_version: 'iOS100',
                           device_type: 'iOS'
      expect(response.status).to eq(200)
      expect(response_json['token']).to eq('update token')
      expect(response_json['os_version']).to eq('iOS100')
    end
  end

  context 'destroy' do
    it 'status 200' do
      delete :destroy, id: device.id, auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq('Ok')
    end
  end
end
