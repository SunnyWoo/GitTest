require 'spec_helper'
require 'stripe_mock'

describe Api::V2::My::OrdersController, type: :controller do
  before { @request.env.merge! api_header(2) }

  before do
    create(:usd_currency_type)
    create(:twd_currency_type)
  end

  let(:user) { create(:user) }
  let(:work) { create(:work) }
  let(:standardized_work) { create(:standardized_work, aasm_state: 'published') }
  let!(:order) { create(:order, :with_stripe, user: user).tap(&:reload).tap(&:save) }
  let(:another_work) { create(:work) }
  let(:coupon) { create(:coupon) }
  let(:uuid) { UUIDTools::UUID.timestamp_create.to_s }
  let!(:fee) { create(:fee, name: 'cash_on_delivery') }

  context 'create' do
    Given(:order_params) do
      {
        uuid: uuid,
        auth_token: user.auth_token,
        currency: 'USD',
        payment_method: 'paypal',
        billing_info: billing_profile_params,
        shipping_info: billing_profile_params,
        order_items: []
      }
    end

    context '#validate_build_order' do
      context 'order_items null' do
        When { put :update, order_params }
        Then { response.status == 400 }
        And { response_json['code'] == 'OrderItemsEmptyError' }
      end

      context 'order_items work not finish' do
        When { order_params.merge!(order_items: [{ work_uuid: work.uuid, quantity: 1 }]) }
        When { put :update, order_params }
        Then { response.status == 400 }
        And { response_json['code'] == 'WorkNotFinishError' }
      end

      context 'order_items work not found' do
        When { put :update, order_params.merge!(order_items: [{ work_uuid: '123', quantity: 1 }]) }
        Then { response.status == 400 }
        And { response_json['code'] == 'WorkNotFoundError' }
      end

      context 'returns 200 with standardized work uuid' do
        When { put :update, order_params.merge!(order_items: [{ work_uuid: standardized_work.uuid, quantity: 1 }]) }
        Then { response.status == 200 }
        And { expect(response).to render_template('api/v3/orders/show') }
        And { Order.last.activities.first.key == 'create' }
      end

      context 'status 200 order_items with work_uuid && downcase coupon' do
        When { work.finish! }
        When { order_params.merge!(order_items: [{ work_uuid: work.uuid, quantity: 1 }]) }
        When { put :update, order_params }
        Then { response.status == 200 }
        And { expect(response).to render_template('api/v3/orders/show') }
        And { Order.last.activities.first.key == 'create' }
      end
    end
  end

  context 'index' do
    it 'return 200' do
      get :index, auth_token: user.auth_token
      expect(response).to render_template('api/v3/orders/index')
    end
  end

  context 'show' do
    it 'return 404' do
      uuid = '76cfd05a-5a62-11e4-a0a3-3c15c2d24fd8'
      get :show, uuid: uuid, auth_token: user.auth_token
      expect(response.status).to eq(404)
      expect(response_json['code']).to eq('RecordNotFoundError')
    end

    it 'return 200' do
      order = user.orders.first
      get :show, uuid: order.uuid, auth_token: user.auth_token
      expect(response).to render_template('api/v3/orders/show')
      expect(assigns(:order)).to eq(order)
    end
  end

  context 'pay' do
    let(:stripe_helper) { StripeMock.create_test_helper }
    let(:payment_id) { paypal_payment.id }
    let(:payment_params) do
      {
        order_uuid: order.uuid,
        payment_method: 'paypal',
        auth_token: user.auth_token
      }
    end
    before { StripeMock.start }
    after { StripeMock.stop }

    before { @stripe_token = stripe_helper.generate_card_token }

    it 'status 200', :vcr do
      patch :pay, payment_params.merge(payment_id: payment_id)
      expect(response.status).to eq(200)
      expect(response).to render_template('api/v3/orders/show')
      expect(assigns(:order).aasm_state).to eq('paid')
      expect(assigns(:order).payment_method).to eq('paypal')
      expect(assigns(:order).payment_id).to eq(payment_id)
    end

    it 'status 200 by payment_method is stripe works', :vcr do
      patch :pay, payment_params.merge(payment_method: 'stripe', payment_id: @stripe_token)
      expect(response.status).to eq(200)
      expect(response).to render_template('api/v3/orders/show')
      expect(assigns(:order).aasm_state).to eq('paid')
      expect(assigns(:order).payment_method).to eq('stripe')
    end

    it 'order uuid error' do
      patch :pay, payment_params.merge(order_uuid: 999)
      expect(response.status).to eq(404)
      expect(response_json['code']).to eq('RecordNotFoundError')
    end

    it "Can't find paypal payment.", :vcr do
      patch :pay, payment_params.merge(payment_id: 'blah')
      res = response_json
      expect(res['code']).to eq('OrderPayError')
      expect(res['error']).to match('paypal')
    end

    it 'uses previous payment method if not given', :vcr do
      order.update(payment_method: 'paypal')
      patch :pay, order_uuid: order.uuid, payment_id: payment_id, auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response).to render_template('api/v3/orders/show')
      expect(assigns(:order).aasm_state).to eq('paid')
    end

    it 'skips pay for non-pending orders', :vcr do
      order.reload
      order.payment_method = 'cash_on_delivery'
      order.pay!
      patch :pay, order_uuid: order.uuid, auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response).to render_template('api/v3/orders/show')
      expect(assigns(:order).aasm_state).to eq('paid')
      expect(assigns(:order).payment_method).to eq('cash_on_delivery')
    end
  end

  context 'update' do
    let(:order_params) do
      {
        uuid: order.uuid,
        auth_token: user.auth_token,
        currency: 'TWD',
        coupon: '',
        billing_info: billing_profile_params,
        shipping_info: billing_profile_params,
        order_items: [work_uuid: work.uuid, quantity: 2],
        message: 'v2 message'
      }
    end
    it 'status 200' do
      work.finish!
      allow_any_instance_of(Work).to receive(:price_in_currency).and_return(300)
      allow_any_instance_of(ArchivedWork).to receive(:price_in_currency).and_return(300)
      put :update, order_params
      expect(response.status).to eq(200)
      order.reload
      expect(response).to render_template('api/v3/orders/show')
      expect(assigns(:order)).to eq(order)
      expect(order.message).to eq('v2 message')
    end

    it 'status 400 UUID format is invalid' do
      work.finish!
      order_params.merge!(currency: 'USD', uuid: 9999)
      put :update, order_params
      expect(response.status).to eq(400)
      expect(response_json['code']).to eq('OrderError')
    end

    context 'update items' do
      before do
        another_work.finish!
        order_params.merge!(currency: 'USD', order_items: [work_uuid: another_work.uuid, quantity: 3])
        put :update, order_params
      end

      it 'replace all items' do
        order.reload
        expect(order.order_items.count).to eq(1)
        expect(response).to render_template('api/v3/orders/show')
        expect(assigns(:order)).to eq(order)
      end

      it 'update price' do
        price = order.reload.order_items.inject(0) do |sum, item|
          sum + item.price_in_currency(order.reload.currency) * item.quantity
        end.round(2)
        expect(response).to render_template('api/v3/orders/show')
        expect(assigns(:order).price).to eq(price)
      end
    end

    context 'Header with Accept-Language' do
      before do
        work.finish!
        @order_params = {
          uuid: order.uuid,
          auth_token: user.auth_token,
          currency: 'USD',
          payment_method: 'paypal',
          billing_info: billing_profile_params,
          shipping_info: billing_profile_params,
          order_items: [
            work_uuid: work.uuid,
            quantity: 1
          ]
        }
      end

      it 'order locale eq zh-TW when available locale zh-TW' do
        @request.env.merge!('HTTP_ACCEPT_LANGUAGE' => 'zh-TW')
        put :update, @order_params
        expect(response.status).to eq(200)
        expect(order.tap(&:reload).locale).to eq('zh-TW')
      end

      it 'order locale eq en when unavailable locale en-US' do
        @request.env.merge!('HTTP_ACCEPT_LANGUAGE' => 'en-US')
        put :update, @order_params
        expect(response.status).to eq(200)
        expect(order.tap(&:reload).locale).to eq('en')
      end
    end
  end

  context 'price' do
    let(:cart_params) do
      {
        auth_token: user.auth_token,
        currency: 'USD',
        coupon: coupon.code,
        order_items: [{
          type: 'shop',
          work_uuid: work.uuid,
          quantity: 2
        }, {
          type: 'create',
          product_model_key: ProductModel.first.key,
          quantity: 3
        }],
        shipping_info: {
          shipping_way: 'standard'
        }
      }
    end

    it 'return status 200' do
      post :price, cart_params
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response_json['meta']['items_count']).to eq(5)
      expect(response_json['meta']['coupon']).to be_nil
      order_json = response_json['order']
      expect(order_json['currency']).to eq('USD')
      expect(order_json['coupon']).to eq(coupon.code)
      expect(order_json['price']['subtotal']).to eq('499.5')
      expect(order_json['price']['discount']).to eq('5.0')
      expect(order_json['price']['shipping_fee']).to eq('0.0')
      expect(order_json['price']['price']).to eq(494.5)
      expect(order_json['display_price']['subtotal']).to eq('$499.50')
      expect(order_json['display_price']['discount']).to eq('$5.00')
      expect(order_json['display_price']['shipping_fee']).to eq('$0.00')
      expect(order_json['display_price']['price']).to eq('$494.50')
    end

    it 'return status 200 with currency TWD' do
      post :price, cart_params.merge!(currency: 'TWD')
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response_json['meta']['items_count']).to eq(5)
      expect(response_json['meta']['coupon']).to be_nil
      order_json = response_json['order']
      expect(order_json['currency']).to eq('TWD')
      expect(order_json['coupon']).to eq(coupon.code)
      expect(order_json['price']['subtotal']).to eq('14995.0')
      expect(order_json['price']['discount']).to eq('150.0')
      expect(order_json['price']['shipping_fee']).to eq('0.0')
      expect(order_json['price']['price']).to eq(14_845.0)
      expect(order_json['display_price']['subtotal']).to eq('NT$14,995')
      expect(order_json['display_price']['discount']).to eq('NT$150')
      expect(order_json['display_price']['shipping_fee']).to eq('NT$0')
      expect(order_json['display_price']['price']).to eq('NT$14,845')
    end

    it 'return status 400 when coupon un valid' do
      post :price, cart_params.merge(coupon: 'xxx')
      expect(response.status).to eq(400)
      expect(response_json['error']).to eq('Cannot use the coupon code.')
      expect(response_json['code']).to eq('InvalidCouponError')
    end

    it 'return status 400 when coupon can\t use ' do
      post :price, cart_params.merge(coupon: create(:coupon, begin_at: Date.tomorrow).code)
      expect(response.status).to eq(400)
      expect(response_json['error']).to eq('Cannot use the coupon code.')
      expect(response_json['code']).to eq('InvalidCouponError')
    end

    it 'return status 200 without coupon code' do
      post :price, cart_params.merge(coupon: '')
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response_json['meta']['items_count']).to eq(5)
      expect(response_json['meta']['coupon']).to be_nil
      order_json = response_json['order']
      expect(order_json['currency']).to eq('USD')
      expect(order_json['coupon']).to eq('')
      expect(order_json['price']['subtotal']).to eq('499.5')
      expect(order_json['price']['discount']).to eq('0.0')
      expect(order_json['price']['shipping_fee']).to eq('0.0')
      expect(order_json['price']['price']).to eq(499.5)
    end

    it 'return status 400 when order_itmes nil' do
      post :price, auth_token: user.auth_token
      expect(response.status).to eq(400)
      expect(response_json['code']).to eq('ApplicationError')
      expect(response_json['error']).to eq("order_items can't be blank")
    end
  end
end
