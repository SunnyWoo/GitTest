require 'spec_helper'

describe Api::V2::CouponsController, type: :controller do
  before { @request.env.merge!(api_header(2)) }

  describe '#validate' do
    it 'returns coupon if found and can use' do
      coupon = create(:coupon, user_usage_count_limit: -1)
      get :validate, code: coupon.code
      expect(response.body).to eq(Api::V2::CouponSerializer.new(coupon).to_json)
    end

    it 'raises error if code not found' do
      get :validate, code: 'not exist'
      expect(response.body).to eq(InvalidCouponError.new.to_json)
    end

    it 'raises error if code cannot be used' do
      coupon = create(:coupon, begin_at: Time.zone.today + 1.day, user_usage_count_limit: -1)
      get :validate, code: coupon.code
      expect(response.body).to eq(InvalidCouponError.new.to_json)
    end
  end
end
