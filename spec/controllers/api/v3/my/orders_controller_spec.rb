require 'spec_helper'
require 'stripe_mock'

describe Api::V3::My::OrdersController, :api_v3, type: :controller do
  before { expect(controller).to receive(:doorkeeper_authorize!).and_call_original }
  before { expect(controller).to receive(:check_user).and_call_original }

  let(:user) { create(:user) }
  let(:work) { create(:work) }
  let(:standardized_work) { create(:standardized_work, aasm_state: 'published') }
  let!(:order) { create(:order, :with_stripe, user: user).reload }
  let(:another_work) { create(:work) }
  let(:coupon) { create(:coupon) }
  let(:uuid) { UUIDTools::UUID.timestamp_create.to_s }
  let!(:fee) { create(:fee, name: 'cash_on_delivery') }

  context 'create', signed_in: :normal do
    Given(:order_params) do
      {
        uuid: uuid,
        access_token: access_token,
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
        When { order_params[:order_items] = [{ work_uuid: work.uuid, quantity: 1 }] }
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
        And { expect(response).to render_template(:show) }
        And { Order.last.activities.first.key == 'create' }
      end

      context 'status 200 order_items with work_uuid && downcase coupon' do
        When { work.finish! }
        When { order_params[:order_items] = [{ work_uuid: work.uuid, quantity: 1 }] }
        When { put :update, order_params }
        Then { response.status == 200 }
        And { expect(response).to render_template(:show) }
        And { Order.last.activities.first.key == 'create' }
        And { Order.last.application == controller.current_application }
      end

      context 'update for repay' do
        Given(:repay_params) do
          {
            uuid: uuid,
            access_token: access_token,
            payment_method: 'paypal',
            pricing_identifier: pricing_identifier
          }
        end
        Given do
          Api::V3::OrderDecorator.any_instance.stub(:pricing_identifier).and_return 'f9e44c4af9377cf992a92759b375b4c0'
        end
        Given!(:order) { create :order, uuid: uuid }

        context 'with correct pricing identifier' do
          Given(:pricing_identifier) { 'f9e44c4af9377cf992a92759b375b4c0' }
          context 'but order had shipping fee unavailable' do
            When { put :update, repay_params }
            Then { expect(response.status).to eq 400 }
          end

          context 'but order had shipping fee unavailable' do
            Given { Order.any_instance.stub(:shipping_fee).and_return(100.0) }
            When { put :update, repay_params }
            Then { expect(response.status).to eq 200 }
            And { expect(response).to render_template(:show) }
          end
        end

        context 'with wrong pricing identifier' do
          Given(:pricing_identifier) { '992a92759b375b4c0f9e44c4af9377cf' }
          When { put :update, repay_params }
          Then { expect(response.status).to eq 400 }
          And { expect(response).not_to render_template(:show) }
        end
      end
    end
  end

  context 'index', signed_in: :normal do
    it 'return 200' do
      get :index, access_token: access_token
      expect(response).to render_template(:index)
    end

    it 'returns specific scope orders if params valid scope provide' do
      2.times { create :paid_order, user: user }
      3.times { create :pending_order, user: user }
      get :index, access_token: access_token, scope: :paid
      expect(response).to render_template(:index)
    end
  end

  context 'show', signed_in: :normal do
    it 'return 404' do
      uuid = '76cfd05a-5a62-11e4-a0a3-3c15c2d24fd8'
      get :show, uuid: uuid, access_token: access_token
      expect(response.status).to eq(404)
      expect(response_json['code']).to eq('RecordNotFoundError')
    end

    it 'return 200 with order uuid' do
      order = user.orders.first
      get :show, uuid: order.uuid, access_token: access_token
      expect(response).to render_template(:show)
    end

    it 'return 200 with order_no' do
      order = user.orders.first
      get :show, uuid: order.order_no, access_token: access_token
      expect(response).to render_template(:show)
    end

    it 'return 404 with incorrect params' do
      order_no = '76cfd05a'
      get :show, uuid: order_no, access_token: access_token
      expect(response.status).to eq(404)
      expect(response_json['code']).to eq('RecordNotFoundError')
    end
  end

  context 'pay', signed_in: :normal do
    let(:stripe_helper) { StripeMock.create_test_helper }
    let(:payment_id) { paypal_payment.id }
    let(:payment_params) do
      {
        order_uuid: order.uuid,
        payment_method: 'paypal',
        access_token: access_token
      }
    end
    before { StripeMock.start }
    after { StripeMock.stop }

    before { @stripe_token = stripe_helper.generate_card_token }
    before { order.calculate_price! }

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
      patch :pay, order_uuid: order.uuid, payment_id: payment_id, access_token: access_token
      expect(response.status).to eq(200)
      expect(response).to render_template('api/v3/orders/show')
      expect(assigns(:order).aasm_state).to eq('paid')
    end

    it 'skips pay for non-pending orders', :vcr do
      order.reload
      order.payment_method = 'cash_on_delivery'
      order.pay!
      patch :pay, order_uuid: order.uuid, access_token: access_token
      expect(response.status).to eq(200)
      expect(response).to render_template('api/v3/orders/show')
      expect(assigns(:order).aasm_state).to eq('paid')
      expect(assigns(:order).payment_info).not_to be_nil
      expect(assigns(:order).payment_method).to eq('cash_on_delivery')
    end

    context 'when payment method is not allowed' do
      let(:payment_params) do
        {
          order_uuid: order.uuid,
          payment_method: 'unknown',
          access_token: access_token
        }
      end
      it 'returns 403' do
        patch :pay, payment_params.merge(payment_id: 'whatever')
        expect(response.status).to eq(403)
        expect(response.body).to eq(PaymentMethodNotAllowedError.new.to_json)
      end
    end
  end

  context 'update', signed_in: :normal do
    let(:order_params) do
      {
        uuid: order.uuid,
        access_token: access_token,
        currency: 'TWD',
        coupon: '',
        billing_info: billing_profile_params,
        shipping_info: billing_profile_params,
        order_items: [work_uuid: work.uuid, quantity: 2],
        message: 'here is message'
      }
    end
    it 'status 200' do
      work.finish!
      allow_any_instance_of(Work).to receive(:price_in_currency).and_return(300)
      allow_any_instance_of(ArchivedWork).to receive(:price_in_currency).and_return(300)
      put :update, order_params
      expect(response.status).to eq(200)
      order.reload
      expect(response).to render_template(:show)
    end

    it 'status 400 UUID format is invalid' do
      work.finish!
      order_params.merge!(currency: 'USD', uuid: 9999)
      put :update, order_params
      expect(response.status).to eq(400)
      expect(response_json['code']).to eq('OrderError')
    end

    context 'update items', signed_in: :normal do
      before do
        another_work.finish!
        order_params.merge!(currency: 'USD', order_items: [work_uuid: another_work.uuid, quantity: 3])
        put :update, order_params
      end

      it 'replace all items' do
        order.reload
        expect(order.order_items.count).to eq(1)
        expect(response).to render_template(:show)
      end

      it 'update price' do
        price = order.reload.order_items.inject(0) do |sum, item|
          sum + item.price_in_currency(order.reload.currency) * item.quantity
        end.round(2)
        expect(order.price).to eq(price)
        expect(response).to render_template(:show)
      end
    end

    context 'Header with Accept-Language', signed_in: :normal do
      before do
        work.finish!
        @order_params = {
          uuid: order.uuid,
          access_token: access_token,
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
        @request.env['HTTP_ACCEPT_LANGUAGE'] = 'zh-TW'
        put :update, @order_params
        expect(response.status).to eq(200)
        expect(order.tap(&:reload).locale).to eq('zh-TW')
      end

      it 'order locale eq en when unavailable locale en-US' do
        @request.env['HTTP_ACCEPT_LANGUAGE'] = 'en-US'
        put :update, @order_params
        expect(response.status).to eq(200)
        expect(order.tap(&:reload).locale).to eq('en')
      end
    end
  end

  context '#destroy', signed_in: :normal do
    context 'soft destroys shipping order' do
      Given(:order) { create :order, user: user, aasm_state: :shipping }
      When { patch :destroy, access_token: access_token, uuid: order.uuid }
      Then { response.status.to_i == 200 }
      And { !order.reload.viewable? }
    end

    context 'returns 403 if order is not shipping' do
      Given(:order) { create :paid_order, user: user }
      When { patch :destroy, access_token: access_token, uuid: order.uuid }
      Then { response.status.to_i == 403 }
      And { order.reload.viewable? }
    end
  end

  context 'price', signed_in: :normal do
    Given(:cart_params) do
      {
        access_token: access_token,
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

    context 'return status 200' do
      When{ post :price, cart_params }
      Then{ expect(response).to be_success }
      And{ expect(response).to render_template(:price) }
    end

    context 'return status 200 without coupon code' do
      When{ post :price, cart_params.merge(coupon: '') }
      Then{ expect(response).to be_success }
      And{ expect(response).to render_template(:price) }
    end

    context 'return status 400 when order_itmes nil' do
      When{ post :price, cart_params.merge(order_items: nil) }
      Then{ expect(response.status).to eq(400) }
      And{ expect(response).not_to render_template(:price) }
      And{ expect(response_json['code']).to eq('ApplicationError') }
      And{ expect(response_json['error']).to eq("order_items can't be blank") }
    end

    context 'return status 400 when coupon un valid' do
      When{ post :price, cart_params.merge(coupon: 'xxx') }
      Then{ expect(response.status).to eq(400) }
      And{ expect(response).not_to render_template(:price) }
      And{ expect(response_json['error']).to eq('Cannot use the coupon code.') }
      And{ expect(response_json['code']).to eq('InvalidCouponError') }
    end

    context 'return status 400 when coupon can\t use ' do
      When{ post :price, cart_params.merge(coupon: create(:coupon, begin_at: Date.tomorrow).code) }
      Then{ expect(response.status).to eq(400) }
      And{ expect(response).not_to render_template(:price) }
      Then{ expect(response_json['error']).to eq('Cannot use the coupon code.') }
      Then{ expect(response_json['code']).to eq('InvalidCouponError') }
    end
  end

  context '#cancel', signed_in: :normal do
    let(:order) { create(:order, aasm_state: aasm_state, user: user) }
    let(:aasm_state) { :pending }
    let(:order_params) { { uuid: order.uuid, access_token: access_token } }

    context 'when order not found' do
      it 'returns 404' do
        put :cancel, uuid: 'xxxx-xxxx-xxxx', access_token: access_token
        expect(response.status).to eq(404)
        expect(response_json['error']).to eq(I18n.t('errors.order_record_not_found'))
      end
    end

    context 'when aasm_state' do
      context 'is pending' do
        it 'returns 200' do
          put :cancel, order_params
          expect(response.status).to eq(200)
          expect(response).to render_template(:show)
        end
      end

      context 'is waiting_for_payment' do
        let(:aasm_state) { :waiting_for_payment }
        it 'returns 200' do
          put :cancel, order_params
          expect(response.status).to eq(200)
          expect(response).to render_template(:show)
        end
      end

      context "is paid can't transfer" do
        let(:aasm_state) { :paid }
        it 'returns 400' do
          put :cancel, order_params
          expect(response.status).to eq(400)
          expect(response_json['error']).to eq(I18n.t('errors.order_cancel_invalid'))
        end
      end

      context "is canceled can't transfer" do
        let(:aasm_state) { :canceled }
        it 'returns 400' do
          put :cancel, order_params
          expect(response.status).to eq(400)
          expect(response_json['error']).to eq(I18n.t('errors.order_cancel_invalid'))
        end
      end
    end
  end
end
