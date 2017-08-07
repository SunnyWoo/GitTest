require 'spec_helper'

RSpec.describe Api::V2::ResetPasswordTokensController, type: :controller do
  before { @request.env.merge!(api_header(2)) }
  Given!(:user) { create :user }
  context '#create' do
    context 'returns 404 if user email is not found' do
      When { post :create, email: 'jackie.chan@duang.com' }
      Then { response.status == 404 }
      And { assert 0, ResetPasswordMailerWorker.jobs.size }
    end

    context 'returns 200 and enqueue ResetPasswordMailerWorker with correct email' do
      When { post :create, email: user.email }
      Then { response.status == 200 }
      And { assert 1, ResetPasswordMailerWorker.jobs.size }
    end

    context 'returns 400 with invalid paramater url' do
      When { post :create, email: user.email, url: 'fake@example.com' }
      Then { response.status == 400 }
      And { assert 0, ResetPasswordMailerWorker.jobs.size }
    end

    context 'returns 200 with both valid paramater email and url' do
      When { post :create, email: user.email, url: 'http://commandp.com' }
      Then { response.status == 200 }
      And { assert 1, ResetPasswordMailerWorker.jobs.size }
    end
  end

  context '#update' do
    context 'returns 422 with wrong reset_password_token' do
      Given(:params) do
        {
          reset_password_token:  'lalalilala',
          password:              'Commandp123',
          password_confirmation: 'Commandp123'
        }
      end
      When { put :update, params }
      Then { response.status == 422 }
      And { !user.reload.valid_password? params[:password] }
    end

    context 'returns 200 with all paramater valid' do
      Given(:params) do
        {
          reset_password_token:  user.send_password_reset_token,
          password:              'Commandp123',
          password_confirmation: 'Commandp123'
        }
      end
      When { put :update, params }
      Then { response.status == 200 }
      And { user.reload.valid_password? params[:password] }
    end

    context 'returns 422 with invalid password' do
      Given(:params) do
        {
          reset_password_token:  user.send_password_reset_token,
          password:              'Comma',
          password_confirmation: 'Comma'
        }
      end
      When { put :update, params }
      Then { response.status == 422 }
      And { !user.reload.valid_password? params[:password] }
    end

    context 'returns 422 with inconsistent password and password_confirmation' do
      Given(:params) do
        {
          reset_password_token:  user.send_password_reset_token,
          password:              'Commandp123',
          password_confirmation: 'Commandp12345'
        }
      end
      When { put :update, params }
      Then { response.status == 422 }
      And { !user.reload.valid_password? params[:password] }
    end
  end
end
