require 'spec_helper'

describe Api::V1::UsersController, type: :controller do
  context 'create' do
    it 'status 200' do
      post :create
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response_json['user_id']).not_to be nil
      expect(response_json['auth_token']).not_to be nil
    end
  end
end
