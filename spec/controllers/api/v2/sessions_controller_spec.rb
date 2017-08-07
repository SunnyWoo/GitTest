require 'rails_helper'

RSpec.describe Api::V2::SessionsController, type: :controller do
  before { @request.env.merge! api_header(2) }

  let!(:user) do
    create(:user,
           email: 'test@commandp.me', password: 'commandp',
           password_confirmation: 'commandp', mobile: '12345678901')
  end

  context '#create' do
    describe 'default sign_in_method: email' do
      it 'returns ok when all params provided' do
        data = { way: 'normal', email: 'test@commandp.me', password_input: 'commandp' }
        post :create, data
        expect(response.status).to eq 200
        expect(response_json['user']['auth_token']).to eq user.reload.auth_token
      end

      it 'returns unprocessable entity with incorrect password' do
        data = { way: 'normal', email: 'test@commandp.me', password_input: 'ggggggggg' }
        post :create, data
        expect(response.status).to eq 422
      end

      it 'when not found when email is incorrect' do
        data = { way: 'normal', email: 'testgg@commandp.me', password_input: 'commandp' }
        post :create, data
        expect(response.status).to eq 401
        expect(response_json['code']).to eq('UserSignInError')
        expect(response_json['error']).to eq(I18n.t('errors.invalid_login_info'))
      end
    end

    describe 'sign_in_method: mobile' do
      Given(:data) { { sign_in_method: 'mobile', mobile: '12345678901', password_input: 'commandp' } }
      context 'no such user' do
        When { post :create, data.merge(mobile: 'no_such_mobile') }
        Then { response.status == 401 }
        Then { response_json['code'] == 'UserSignInError' }
        And { response_json['error'] == I18n.t('errors.invalid_login_info') }
      end

      context 'wrong password' do
        When { post :create, data.merge(password_input: 'wrong password') }
        Then { response.status == 401 }
      end

      context 'login ok' do
        When { post :create, data }
        Then { response.status == 200 }
      end
    end
  end

  context '#destroy' do
    it 'returns ok when auth_token is correct' do
      old_token = user.auth_token
      delete :destroy, auth_token: user.auth_token
      expect(response.status).to eq 200
      expect(user.auth_token).to be_nil
      expect(user.auth_tokens.where(token: old_token).count).to eq 0
    end

    it 'returns unauthorized when auth_token is invalid' do
      delete :destroy, auth_token: 'gggggggg'
      expect(response.status).to eq 401
    end

    it 'returns unauthorized when auth_token is not provided' do
      delete :destroy
      expect(response.status).to eq 401
    end
  end
end
