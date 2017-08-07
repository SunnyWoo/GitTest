require 'rails_helper'

RSpec.describe Api::V3::ConfirmationsController, :api_v3, type: :controller do
  context '#create', signed_in: false do
    Given(:user) { create :user, :without_confirmed }
    context 'returns 404 with wrong email' do
      When { post :create, access_token: access_token, email: 'wtf@commandp.com' }
      Then { response.status == 404 }
      And { user.reload.reset_password_token.nil? }
    end

    context 'returns 400 url is invalid' do
      When { post :create, access_token: access_token, email: user.email, url: 'invalid' }
      Then { response.status == 400 }
    end

    context 'returns 400 when user is already confirmed' do
      Given(:confirmed_user) { create :user }
      When {
        post :create, access_token: access_token,
                      email: confirmed_user.email,
                      url: token.application.redirect_uri
      }
      Then { response.status == 400 }
    end

    context 'returns 400 when confirmation_sent_at within 10 min' do
      When { user.update confirmation_sent_at: Time.zone.now }
      When { post :create, access_token: access_token, email: user.email, url: token.application.redirect_uri }
      Then { response.status == 400 }
    end

    context 'returns 200 with correct email' do
      When { post :create, access_token: access_token, email: user.email, url: token.application.redirect_uri }
      Then { response.status == 200 }
      And { assert_equal 1, ConfirmationMailerWorker.jobs.size }
      And { response_json == { massage: 'success', email: user.email }.as_json }
    end

    context 'returns 200 with correct email without url' do
      When { post :create, access_token: access_token, email: user.email }
      Then { response.status == 200 }
      And { assert_equal 1, ConfirmationMailerWorker.jobs.size }
      And { response_json == { massage: 'success', email: user.email }.as_json }
    end
  end

  context '#show', signed_in: false do
    Given(:user) { create :user, :without_confirmed }
    context 'returns ok with correct confirmation_token' do
      Given(:params) { { confirmation_token: user.send_confirmation_token(token.application.redirect_uri) } }
      When { get :show, { access_token: access_token }.merge(params) }
      Then { response.status == 200 }
      And { user.reload.confirmed? == true }
      And { expect(response).to render_template('api/v3/profiles/show') }
    end

    context 'returns ok with incorrect confirmation_token' do
      Given(:params) { { confirmation_token: 'incorrect' } }
      When { get :show, { access_token: access_token }.merge(params) }
      Then { response.status == 422 }
      And { user.reload.confirmed? == false }
    end
  end
end
