require 'spec_helper'

RSpec.describe RedeemsController, type: :controller do
  let(:work) { create(:work, :with_iphone6_model) }
  let(:redeem_work) { create(:work, :redeem) }
  let(:coupon) { create(:coupon) }
  let(:redeem_coupon) { create(:coupon, condition: 'simple',
                                        coupon_rules: [create(:work_rule, work_gids: [redeem_work.to_gid_param])]) }
  let(:redeem_coupon_for_product) { create(:coupon, condition: 'simple',
                                                    coupon_rules: [create(:product_model_rule, product_model_ids: [work.product.id])]) }

  describe '#new' do
    it 'returns 404 when without gid' do
      get :new, locale: 'zh-TW'
      expect(response.status).to eq(404)
    end

    it 'returns 200 when work work_type is not redeem gid' do
      get :new, gid: work.to_sgid.to_s, locale: 'zh-TW'
      expect(response.status).to eq(404)
    end

    it 'returns 200 with redeem_work' do
      get :new, gid: redeem_work.to_sgid.to_s, locale: 'zh-TW'
      expect(response.status).to eq(200)
    end
  end

  describe '#verify' do
    context 'when coupon is not found' do
      When { post :verify, redeem_code: '', locale: 'zh-TW' }
      Then { response.status == 404 }
      And { response_json['code'] == 'RecordNotFoundError' }
    end

    it 'returns false when unvalid redeem code' do
      post :verify, redeem_code: coupon.code, gid: redeem_work.to_sgid.to_s, locale: 'zh-TW'
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq false
    end

    it 'returns true with valid redeem code' do
      post :verify, redeem_code: redeem_coupon.code, gid: redeem_work.to_sgid.to_s, locale: 'zh-TW'
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq true
    end

    it 'returns true with not redeem_work but the redeem product of redeem_work' do
      params = {
        redeem_code: redeem_coupon_for_product.code,
        gid: work.to_sgid.to_s,
        locale: 'zh-TW'
      }
      post :verify, params
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq true
    end
  end

  describe '#create' do
    it 'returns true with redeem_code && redeem_work' do
      params = {
        redeem_code: redeem_coupon.code,
        gid: redeem_work.to_sgid.to_s,
        shipping_info: billing_profile_params
      }
      post :create, params.merge(locale: 'zh-TW')
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq true
      order = Order.last
      expect(response_json['order_no']).to eq(order.order_no)
      expect(order.aasm_state).to eq('paid')
      expect(order.price).to eq(0)
      expect(order.discount).to eq(0)
    end

    it 'returns 200 and false with not redeem_work' do
      params = {
        redeem_code: coupon.code,
        gid: work.to_sgid.to_s,
        shipping_info: billing_profile_params
      }
      post :create, params.merge(locale: 'zh-TW')
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq false
    end

    context 'when coupon is not found' do
      When { post :create, redeem_code: '', gid: redeem_work.to_sgid.to_s, locale: 'zh-TW' }
      Then { response.status == 404 }
      And { response_json['code'] == 'RecordNotFoundError' }
    end
  end
end
