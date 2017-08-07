require 'spec_helper'

describe Api::V3::ResetPasswordTokensController, :api_v3, type: :controller do
  Given!(:user) { create :user }
  context '#create', signed_in: false do
    When { expect(user.reload.reset_password_token).to be_nil }
    context 'returns 404 with wrong email' do
      When { post :create, access_token: access_token, email: 'wtf@commandp.com' }
      Then { response.status == 404 }
      And { user.reload.reset_password_token.nil? }
    end

    context 'returns 200 with correct email' do
      When { post :create, access_token: access_token, email: user.email }
      Then { response.status == 200 }
      And { assert_equal 1, ResetPasswordMailerWorker.jobs.size }
      And { response_json == { massage: 'success', email: user.email }.as_json }
    end

    context 'returns 200 with correct email and url nil' do
      When { post :create, access_token: access_token, email: user.email, url: nil }
      Then { response.status == 200 }
      And { assert_equal 1, ResetPasswordMailerWorker.jobs.size }
      And { response_json == { massage: 'success', email: user.email }.as_json }
    end

    context 'returns 400 if paramater url is provided and invalid' do
      When { post :create, access_token: access_token, email: user.email, url: 'ggyy' }
      Then { response.status == 400 }
    end

    context 'returns 400 if paramater url is provided but illegal' do
      When { post :create, access_token: access_token, email: user.email, url: 'http://example.com' }
      Then { response.status == 400 }
    end

    context 'returns 200 if paramater url is provided and legal' do
      When { post :create, access_token: access_token, email: user.email, url: token.application.redirect_uri }
      Then { response.status == 200 }
    end
  end

  context '#update', signed_in: false do
    context 'returns ok with both correct reset_password_token and params' do
      Given(:params) do
        {
          reset_password_token:  user.send_password_reset_token,
          password:              'Commandp123',
          password_confirmation: 'Commandp123'
        }
      end
      When { put :update, { access_token: access_token }.merge(params) }
      Then { response.status == 200 }
      And { user.reload.valid_password? params[:password] }
    end

    context 'returns 422 with correct reset_password_token and incorrect params' do
      Given(:params) do
        {
          reset_password_token:  user.send_password_reset_token,
          password:              'Commandp123',
          password_confirmation: 'Commandp12334'
        }
      end
      When { put :update, { access_token: access_token }.merge(params) }
      Then { response.status == 422 }
      And { !user.reload.valid_password?(params[:password]) }
    end

    context 'returns 422 with not enough length of password' do
      Given(:params) do
        {
          reset_password_token:  user.send_password_reset_token,
          password:              'Comma',
          password_confirmation: 'Comma'
        }
      end
      When { put :update, { access_token: access_token }.merge(params) }
      Then { response.status == 422 }
      And { !user.reload.valid_password?(params[:password]) }
    end

    context 'returns 422 without params password_confirmation' do
      Given(:params) do
        {
          reset_password_token:  user.send_password_reset_token,
          password:              'Comma'
        }
      end
      When { put :update, { access_token: access_token }.merge(params) }
      Then { response.status == 422 }
      And { !user.reload.valid_password?(params[:password]) }
    end

    context 'returns 422 with incorrect reset_password_token' do
      Given(:params) do
        {
          reset_password_token:  'make it fake',
          password:              'Commandp123',
          password_confirmation: 'Commandp123'
        }
      end
      When { put :update, { access_token: access_token }.merge(params) }
      Then { response.status == 422 }
      And { !user.reload.valid_password?(params[:password]) }
    end
  end
end
