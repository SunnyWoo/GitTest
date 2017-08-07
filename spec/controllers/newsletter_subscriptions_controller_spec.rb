require 'spec_helper'

RSpec.describe NewsletterSubscriptionsController, type: :controller do

  describe '#create' do
    it 'with local zh-TW' do
      email = 'abc@mail.com'
      post :create, locale: 'zh-TW', newsletter_subscription: { email: email }
      expect(response.status).to eq(200)
      expect(response.body).to eq("{\"status\":\"ok\",\"message\":\"成功寄出！感謝您\"}")
      newsletter_subscription = NewsletterSubscription.last
      expect(newsletter_subscription.email).to eq(email)
      expect(newsletter_subscription.locale).to eq('zh-TW')
    end

    it 'with local en' do
      email = 'abc2@mail.com'
      post :create, locale: 'en', newsletter_subscription: { email: email}
      newsletter_subscription = NewsletterSubscription.last
      expect(newsletter_subscription.email).to eq(email)
      expect(newsletter_subscription.locale).to eq('en')
    end

    it 'with country_code TW' do
      request.env['REMOTE_ADDR'] = '202.39.253.11'
      post :create, locale: 'zh-TW', newsletter_subscription: { email: Faker::Internet.email }
      expect(NewsletterSubscription.last.country_code).to eq('TW')
    end

    it 'with country_code JP' do
      request.env['REMOTE_ADDR'] = '203.209.152.96'
      post :create, locale: 'ja', newsletter_subscription: { email: Faker::Internet.email }
      expect(NewsletterSubscription.last.country_code).to eq('JP')
    end

    it 'valid uniq' do
      email = 'uniq@mail.com'
      post :create, locale: 'zh-TW', newsletter_subscription: { email: email }
      expect(NewsletterSubscription.last.email).to eq(email)

      post :create, locale: 'zh-TW', newsletter_subscription: { email: email }
      expect(response.status).to eq(400)
      expect(response.body).to eq("{\"status\":\"Error\",\"message\":[\"Email 已經被使用\"]}")
    end

    it 'valid email' do
      post :create, locale: 'zh-TW', newsletter_subscription: { email: 'abc' }
      expect(response.status).to eq(400)
      expect(response.body).to eq("{\"status\":\"Error\",\"message\":[\"Email 是無效的\"]}")
    end
  end

end
