require 'spec_helper'

describe Api::V3::CartsController, :api_v3, type: :controller do
  before { expect(controller).to receive(:doorkeeper_authorize!).and_call_original }
  before { expect(controller).to receive(:check_user).and_call_original }

  Given!(:work) { create(:work) }
  Given!(:quantity) { rand(10) + 1 }
  Given(:cart) { CartSession.new(controller: controller, user_id: user.id) }

  describe 'GET /cart' do
    context 'when a user signed in', signed_in: :guest do
      Given(:item) { response_json['cart']['order_items'][0] }
      Given(:order) { cart.build_tmp_order }

      before do
        cart.add_items(work.to_gid, quantity)
        cart.save
      end

      When { get :show, access_token: access_token }
      Then { response.status == 200 }
      And { expect(response).to render_template(:show) }
    end
  end

  describe 'DELETE /cart' do
    context 'destroy cart', signed_in: :normal do
      before do
        work2 = create(:work)
        cart.add_items(work.to_gid, quantity)
        cart.add_items(work2.to_gid, quantity)
        cart.save
      end

      When { delete :destroy, access_token: access_token }
      Then { response.status == 200 }
      And { response_json['meta']['items_count'] == 0 }
    end
  end

  describe 'PUT /api/cart' do
    context 'update coupon', signed_in: :normal do
      context 'valid coupon' do
        Given!(:coupon) { create(:coupon) }
        When { put :update, access_token: access_token, coupon_code: coupon.code }
        Then { expect(response).to render_template(:show) }
      end

      context 'invalid coupon' do
        When { put :update, access_token: access_token, coupon_code: 'bad_coupon_code' }
        Then { response.status == 400 }
        And { response_json['error'] == 'Invalid parameter coupon_code' }
      end

      context 'clear coupon code' do
        Given!(:coupon) { create(:coupon) }
        before do
          cart.apply_coupon_code(coupon.code)
          cart.save
          cart.build_tmp_order
        end
        When { put :update, access_token: access_token, clear_coupon_code: 'true' }
        Then { expect(response).to render_template(:show) }
      end

      context 'valid payment' do
        Given(:payment) { Order.payments.sample }
        When { put :update, access_token: access_token, order: { payment: payment } }
        Then { response.status == 200 }
        Then { expect(response).to render_template(:show) }
      end

      context 'currency' do
        When { put :update, access_token: access_token, order: { currency: 'CNY' } }
        Then { response.status == 200 }
        Then { expect(response).to render_template(:show) }
      end

      context 'message' do
        When { put :update, access_token: access_token, order: { message: 'message' } }
        Then { response.status == 200 }
        And { assigns(:order).message == 'message' }
      end

      context 'order_info' do
        Given(:order_info) do
          {
            models: ['mugs'],
            images: ['http://xxxx/xxx.png'],
            memo: 'memo'
          }
        end
        When { put :update, access_token: access_token, order: { order_info: order_info } }
        Then { response.status == 200 }
        And { assigns(:order).order_info[:models] == order_info[:models] }
        And { assigns(:order).order_info[:images] == order_info[:images] }
        And { assigns(:order).order_info[:memo] == order_info[:memo] }
      end

      context 'billing_info, shipping_info' do
        Given(:billing_info_params) { attributes_for(:billing_info) }
        Given(:response_billing_info) { response_json['cart']['billing_info'] }
        Given(:billing_info) { BillingInfo.new(billing_info_params) }

        Given(:shipping_info_params) { attributes_for(:shipping_info) }
        Given(:response_shipping_info) { response_json['cart']['shipping_info'] }
        Given(:shipping_info) { ShippingInfo.new(shipping_info_params) }

        Given(:order_params) { { billing_info: billing_info_params, shipping_info: shipping_info_params } }
        When { put :update, access_token: access_token, order: order_params }
        Then { expect(response).to render_template(:show) }
      end
    end
  end

  describe 'POST /api/cart/check_out' do
    context 'cart is empty', signed_in: :normal do
      When { post :check_out, access_token: access_token }
      Then { response.status == 400 }
      And { response_json['code'] == 'CartIsEmptyError' }
    end

    context 'check out success', signed_in: :normal do
      Given(:billing_info_params) { attributes_for(:billing_info) }
      Given(:response_billing_info) { response_json['cart']['billing_info'] }
      Given(:billing_info) { BillingInfo.new(billing_info_params) }

      Given(:shipping_info_params) { attributes_for(:shipping_info) }
      Given(:response_shipping_info) { response_json['cart']['shipping_info'] }
      Given(:shipping_info) { ShippingInfo.new(shipping_info_params) }

      Given(:order_params) { { billing_info: billing_info_params, shipping_info: shipping_info_params } }
      Given(:options) { { url_options: controller.url_options } }

      before do
        cart.add_items(work.to_gid, quantity)
        cart.update_check_out(order_params.merge(message: 'here is message'))
        cart.save
      end
      When { post :check_out, access_token: access_token }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/orders/show') }
      Given(:order) { Order.last }
      And { order.message == 'here is message' }
      And { order.application == controller.current_application }
      And { expect(order.checked_out_at).to be_present }
    end
  end
end
