require 'spec_helper'

describe Api::V3::CouponsController, :api_v3, type: :controller do
  context '#validate' do
    context 'with current_user', signed_in: :normal do
      context 'returns coupon info if coupon is fresh as well as valid' do
        Given(:coupon) { create :coupon }
        When { get :validate, code: coupon.code, access_token: access_token }
        Then { response.status == 200 }
        And { expect(response).to render_template(:show) }
      end

      # context 'returns true if coupon bind an unpaid order' do
      #   Given(:coupon) { create :coupon, user_usage_count_limit: 1 }
      #   before { create :order, user: user, coupon: coupon }
      #   When { get :validate, code: coupon.code, access_token: access_token }
      #   Then { response.status == 200 }
      #   And { expect(response).to render_template(:show) }
      # end

      context 'when order has paid' do
        context 'returns false with coupon reaches user_usage_count_limit' do
          Given(:coupon) { create :coupon, usage_count_limit: 3, user_usage_count_limit: 1 }
          When do
            order = create :order, user: user, coupon: coupon
            order.pay
            get :validate, code: coupon.code, access_token: access_token
          end
          Then { response.status == 400 }
          And { expect(response.body).to eq(InvalidCouponError.new.to_json) }
        end

        context 'returns true with coupon unreached user_usage_count_limit' do
          Given(:coupon) { create :coupon, usage_count_limit: 3, user_usage_count_limit: 3 }
          When do
            order = create :order, user: user, coupon: coupon
            order.pay
            get :validate, code: coupon.code, access_token: access_token
          end
          Then { response.status == 200 }
          And { expect(response).to render_template(:show) }
        end
      end
    end

    context 'without current_user', signed_in: false do
      context 'returns coupon info if coupon is valid' do
        Given(:coupon) { create :coupon, user_usage_count_limit: -1 }
        When { get :validate, code: coupon.code, access_token: access_token }
        Then { response.status == 200 }
        And { expect(response).to render_template(:show) }
      end

      context 'returns invalid coupon error if coupon is not suit for used without a user' do
        Given(:coupon) { create :coupon, user_usage_count_limit: 2 }
        When { get :validate, code: coupon.code, access_token: access_token }
        Then { response.status == 400 }
        And { expect(response.body).to eq(InvalidCouponError.new.to_json) }
      end

      context 'returns invalid coupon error if coupon is used' do
        Given(:coupon) { create :coupon, usage_count: 1, usage_count_limit: 1 }
        When { get :validate, code: coupon.code, access_token: access_token }
        Then { response.status == 400 }
        And { expect(response.body).to eq(InvalidCouponError.new.to_json) }
      end

      context 'returns invalid coupon error if coupon is not found' do
        When { get :validate, code: 'fn2187', access_token: access_token }
        Then { expect(response.body).to eq(InvalidCouponError.new.to_json) }
      end
    end
  end
end
