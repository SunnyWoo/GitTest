require 'rails_helper'

RSpec.describe Api::V2::RegistrationsController, type: :controller do
  before { @request.env.merge! api_header(2) }
  context '#create' do
    context 'Default: register_method is email' do
      Given(:data) { { email: 'test@commandp.com', password: 'commandp', password_confirmation: 'commandp' } }
      it 'returns ok when all params is provided' do
        post :create, data
        expect(response.status).to eq 200
        expect(User.count).to eq 1
        expect(response_json['user']['auth_token']).to eq User.last.auth_token
      end

      it 'returns unprocessable entity when password and password_confirmation is not consistent' do
        data.merge!(password_confirmation: 'commandppp')
        post :create, data
        expect(response.status).to eq 422
      end

      it 'returns unprocessable entity when password length is shorter than 8' do
        data.merge!(password: 'command', password_confirmation: 'command')
        data = { email: 'test@commandp.com', password: 'command', password_confirmation: 'command' }
        post :create, data
        expect(response.status).to eq 422
      end

      it 'returns unprocessable entity when email has been used' do
        User.create(data)
        data = { email: 'test@commandp.com', password: 'commandg', password_confirmation: 'commandg' }
        post :create, data
        expect(response.status).to eq 422
      end
    end

    context 'When register_method is mobile' do
      Given(:data) do
        {
          mobile: '18516108494', code: '123456', register_method: 'mobile',
          password: 'commandp', password_confirmation: 'commandp'
        }
      end

      context 'verify false' do
        When { allow_any_instance_of(MobileVerifyService).to receive(:verify).and_return(false) }
        When { post :create, data }
        Then { response.status == 401 }
        And { response_json['code'] == 'MobileVerificationFailedError' }
      end

      context 'return ok' do
        When { allow_any_instance_of(MobileVerifyService).to receive(:verify).and_return(true) }
        When { post :create, data }
        Then { response.status == 200 }
        And { User.count == 1 }
        And { response_json['user']['auth_token'] == User.last.auth_token }
        And { User.last.role == 'normal' }
        And { response_json['user']['email'] == User.last.email }
        And { User.last.confirmed? == true }
      end

      context 'return unprocessable when user record is not valid' do
        Given!(:user) { create(:user, mobile: data[:mobile]) }
        When { allow_any_instance_of(MobileVerifyService).to receive(:verify).and_return(true) }
        When { post :create, data }
        Then { response.status == 422 }
        And { response_json['code'] == 'RecordInvalidError' }
      end
    end
  end
end
