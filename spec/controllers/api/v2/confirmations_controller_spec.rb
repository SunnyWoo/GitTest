require 'rails_helper'

RSpec.describe Api::V2::ConfirmationsController, type: :controller do
  before { @request.env.merge! api_header(2) }

  context '#create', signed_in: false do
    Given(:user) { create :user, :without_confirmed }
    context 'returns 404 with wrong email' do
      When { post :create, email: 'wtf@commandp.com' }
      Then { response.status == 404 }
      And { user.reload.reset_password_token.nil? }
    end

    context 'returns 200 with correct email' do
      When { post :create, email: user.email, url: 'http://commandp.com' }
      Then { response.status == 200 }
      And { assert_equal 1, ConfirmationMailerWorker.jobs.size }
      And { response_json == { massage: 'success', email: user.email }.as_json }
    end

    context 'returns 404 with wrong url' do
      When { post :create, email: user.email, url: 'wrong' }
      Then { response.status == 400 }
    end
  end

  context '#show', signed_in: false do
    Given(:user) { create :user, :without_confirmed }
    context 'returns ok with correct confirmation_token' do
      When { get :show, confirmation_token: user.send_confirmation_token('http://commandp.com') }
      Then { response.status == 200 }
      And { user.reload.confirmed? == true }
    end

    context 'returns ok with incorrect confirmation_token' do
      When { get :show, confirmation_token: 'incorrect' }
      Then { response.status == 422 }
      And { user.reload.confirmed? == false }
    end
  end
end
