require 'spec_helper'

describe Api::V1::CouponsController, type: :controller do
  before { @request.env.merge! api_header(1) }

  let(:coupon) { create(:coupon, user_usage_count_limit: -1) }

  context 'validate' do
    it 'status 200' do
      get :validate, code: coupon.code
      expect(response_json['title']).to eq(coupon.title)
    end

    it 'status 200, code downcase' do
      get :validate, code: coupon.code
      expect(response_json['title']).to eq(coupon.title)
    end

    it 'status 200, code with space' do
      code = "     #{coupon.code}     "
      get :validate, code: code
      expect(response_json['title']).to eq(coupon.title)
    end

    it 'status Error, code null' do
      get :validate, {}
      expect(response_json['status']).to eq('Error')
      expect(response_json['message']).to eq('Missing code parameter')
    end

    it 'status Error, code unvalid' do
      get :validate, code: 'abc123'
      expect(response_json['status']).to eq('Error')
      expect(response_json['message']).to eq('Code isn\'t exist')
    end

    it 'status Error, code is used' do
      coupon = create(:coupon, usage_count: 1, user_usage_count_limit: -1)
      get :validate, code: coupon.code
      expect(response_json['status']).to eq('Error')
      expect(response_json['message'][0]).to eq('Code is used')
    end

    it 'status Error, code is expired' do
      Timecop.freeze(Time.zone.yesterday)
      coupon = create(:coupon, expired_at: Time.zone.today, user_usage_count_limit: -1)
      Timecop.return
      get :validate, code: coupon.code
      expect(response_json['status']).to eq('Error')
      expect(response_json['message'][0]).to eq('Code is expired')
    end
  end
end
