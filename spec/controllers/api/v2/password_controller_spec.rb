require 'spec_helper'

RSpec.describe Api::V2::PasswordController, type: :controller do
  before { @request.env.merge!(api_header(2)) }
  Given!(:user) { create :user }

  context '#update' do
    context 'returns 200' do
      Given(:params) do
        {
          auth_token:            user.auth_token,
          password:              'Commandp123',
          password_confirmation: 'Commandp123'
        }
      end
      When { put :update, params }
      Then { response.status == 200 }
      And { user.reload.valid_password? params[:password] }
    end

    context 'returns 401 when auth_token fail' do
      Given(:params) do
        {
          auth_token:            'auth_tokenxxxxxx',
          password:              'Commandp123',
          password_confirmation: 'Commandp123'
        }
      end
      When { put :update, params }
      Then { response.status == 401 }
    end

    context 'returns 422 with inconsistent password and password_confirmation' do
      Given(:params) do
        {
          auth_token:            user.auth_token,
          password:              'Commandp12345',
          password_confirmation: 'Commandp123'
        }
      end
      When { put :update, params }
      Then { response.status == 422 }
    end
  end
end
