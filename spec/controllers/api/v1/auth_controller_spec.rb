require 'spec_helper'

describe Api::V1::AuthController, type: :controller do
  before do
    @fb_user = { id: '100007755945807', access_token: 'CAAIQA1h4nZBcBACEF',
                 email: '1407807568@tfbnw.net' }
  end

  context 'create' do
    it 'status 200' do
      allow_any_instance_of(ApiAuthentication).to(
        receive(:authenticated?).and_return(true))
      allow_any_instance_of(ApiAuthentication).to(
        receive(:sign_in).and_return(true))
      allow_any_instance_of(ApiAuthentication).to(
        receive(:user).and_return(create(:user)))
      params = { provider: 'facebook', uid: @fb_user[:id],
                 access_token: @fb_user[:access_token], email: @fb_user[:email] }
      post :create, params
      expect(response.status).to eq(200)
      expect(response_json['user_id']).not_to be_nil
      expect(response_json['auth_token']).not_to be_nil
      user = User.find response_json['user_id']
      expect(user.current_sign_in_at).not_to be_nil
      expect(user.current_sign_in_ip).not_to be_nil
    end

    it 'miss access_token, status 401' do
      allow_any_instance_of(ApiAuthentication).to(
        receive(:authenticated?).and_return(false))
      allow_any_instance_of(ApiAuthentication).to receive(:error).and_return('\
      message: An active access token must be used to query information \
      about the current user. [HTTP 400]')
      params = { provider: 'facebook', uid: 321, email: 'zh@facebook.com' }
      post :create, params
      expect(response.status).to eq(401)
      expect(response_json['message']).to(
        match('message: An active access token'))
    end
  end

  context 'destroy' do
    let!(:user) { create(:user).tap(&:generate_token) }

    it 'success' do
      delete :destroy, auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq('success')
    end
  end
end
