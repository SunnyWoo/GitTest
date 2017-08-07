require 'spec_helper'

describe MobileViewController, type: :controller do
  describe '#faq' do
    it 'returns 200' do
      get :faq, locale: 'zh-TW'
      expect(response.status).to eq(200)
    end
  end

  describe '#code' do
    it 'returns 200' do
      expect_any_instance_of(SmsKingService).to receive(:sms_fire).and_return("kmsgid=123096601\n")
      get :code, locale: 'zh-TW', mobile: '0910000123'
      expect(response.status).to eq(200)
    end
  end
end
