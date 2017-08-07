require 'spec_helper'

describe Api::V2::AuthsController, type: :controller do
  before { @request.env.merge! api_header(2) }
  Given!(:user) { create(:user) }
  Given(:api_auth) { ApiAuthentication.new(api_params) }
  Given(:fb_user) { { id: '100007755945807', access_token: 'CAAIQA1h4nZBcBACEF', email: '1407807568@tfbnw.net' } }
  Given(:api_params) do
    {
      provider: 'facebook', uid: fb_user[:id],
      access_token: fb_user[:access_token], email: fb_user[:email]
    }
  end

  describe 'POST create' do
    context 'auth successfully' do
      before { expect(ApiAuthentication).to receive(:new).and_return(api_auth) }
      before { expect(api_auth).to receive(:user).and_return(user).at_least(:once) }
      Given(:activity) { Logcraft::Activity.last }
      When { post :create, api_params }
      Then { response.status == 200 }
      And { response_json['user']['user_id'] == user.id }
      And { response_json['user']['auth_token'] == user.tap(&:reload).auth_token }
      And { response_json['user']['email'] == user.email }
      And { response_json['user']['mobile'] == user.mobile }
      And { response_json['user']['mobile_country_code'] == user.mobile_country_code }
      And { response_json['user']['username'] == user.username }
      And { response_json['user']['first_name'] == user.first_name }
      And { response_json['user']['last_name'] == user.last_name }
      And { response_json['user']['birthday'] == user.birthday }
      And { response_json['user']['avatar']['thumb'] == user.avatar.url }
      And { activity.key == 'sign_in' }
      And { activity.extra_info[:provider] == api_params[:provider] }
      And { activity.extra_info[:auth_token] == user.auth_token }
    end

    context 'failed' do
      context 'Unauthorized' do
        before { expect(ApiAuthentication).to receive(:new).and_return(api_auth) }
        before { expect(api_auth).to receive(:user).and_return(error: 'Unauthorized').at_least(:once) }
        When { post :create, api_params }
        Then { response.status == 401 }
      end

      context 'when provider is invalid' do
        When { post :create, api_params.merge!(provider: 'fasdf') }
        Then { response.status == 404 }
      end

      context 'returns bad request when access_token is invalid' do
        Given(:error) { OpenStruct.new(parsed: { 'error' => 'Invalid AccessToken' }) }
        When { expect(Omniauth).to receive(:verify_facebook).and_raise(OAuth2::Error, error) }
        When { post :create, api_params.merge!(access_token: 'wtf') }
        Then { response.status == 400 }
      end

      context 'try to merge guest but old_auth_token is not valid: guest user is not found' do
        before { expect(ApiAuthentication).to receive(:new).and_return(api_auth) }
        before { expect(api_auth).to receive(:user).and_return(user).at_least(:once) }
        When { post :create, api_params.merge!(old_auth_token: '12345') }
        Then { response.status == 404 }
      end
    end
  end
end
