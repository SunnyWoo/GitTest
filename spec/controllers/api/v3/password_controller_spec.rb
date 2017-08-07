require 'spec_helper'

describe Api::V3::PasswordController, :api_v3, type: :controller do
  Given!(:user) { create :user }
  context '#update', signed_in: :normal do
    context 'returns 200' do
      Given(:params) do
        {
          access_token:          access_token,
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
          access_token:            'access_token_xxxxxx',
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
          access_token:          access_token,
          password:              'Commandp12345',
          password_confirmation: 'Commandp123'
        }
      end
      When { put :update, params }
      Then { response.status == 422 }
    end
  end
end
