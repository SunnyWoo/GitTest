require 'spec_helper'

describe Api::V3::NewsletterSubscriptionsController, :api_v3, type: :controller do
  describe 'POST /api/newsletter_subscriptions', signed_in: false do
    it 'creates newsletter subscription with given email' do
      post :create, access_token: access_token, email: 'xxx@xxx.xx'
      newsletter_subscription = NewsletterSubscription.last
      expect(response.status).to eq(201)
      expect(response).to render_template('api/v3/newsletter_subscriptions/show')
      expect(assigns(:newsletter_subscription)).to eq(newsletter_subscription)
    end

    it 'does not return newsletter subscription with invalid email format' do
      post :create, access_token: access_token, email: 'xxxxxx'
      expect(response.status).to eq(422)
    end
  end
end
