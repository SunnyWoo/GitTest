require 'spec_helper'
require 'stripe_mock'

describe Api::V1::My::OrdersController, type: :controller do
  before { @request.env.merge! api_header(1) }
  before do
    CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
    CurrencyType.create(name: 'TWD', code: 'TWD', rate: 1)
  end

  let(:user) { create(:user) }
  let(:work) { create(:work) }
  let!(:order) { create(:order, user: user) }
  let(:another_work) { create(:work) }
  let(:coupon) { create(:coupon) }
  let!(:fee) { create(:fee, name: 'cash_on_delivery') }

  context 'index' do
    it 'status 200' do
      get :index, auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response_json.size).to eq(1)
      expect(response_json[0]['uuid']).not_to be nil
    end
    it 'miss auth_token' do
      get :index
      expect(response_json['status']).to eq('error')
      expect(response_json['message']).to(match('auth_token'))
    end
  end

  context 'show url without locale' do
    it 'status 200 by uuid' do
      get :show, uuid: order.uuid, auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response_json['uuid']).to eq(order.uuid)
      expect(response_json['order_no']).to eq(order.order_no)
      expect(response_json['status']).to eq(I18n.t("order.state.#{order.aasm_state}"))
    end

    it 'status 404' do
      get :show, uuid: 9999, auth_token: user.auth_token
      expect(response.status).to eq(404)
      expect(response_json['message']).to eq('Not found')
    end
  end

  context 'show url with locale' do
    it 'returns order detial when found by given uuid and local = en' do
      get :show, uuid: order.uuid, locale: 'en', auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response_json['uuid']).to eq(order.uuid)
      expect(response_json['order_no']).to eq(order.order_no)
      expect(response_json['status']).to eq(I18n.t("order.state.#{order.aasm_state}"))
    end

    it 'returns order detial when found by given uuid and local = zh-TW' do
      local = 'zh-TW'
      I18n.locale = local
      get :show, uuid: order.uuid, locale: local, auth_token: user.auth_token
      expect(response.status).to eq(200)
      expect(response_json['uuid']).to eq(order.uuid)
      expect(response_json['order_no']).to eq(order.order_no)
      expect(response_json['status']).to eq(I18n.t("order.state.#{order.aasm_state}"))
    end

    it 'returns 404 when not found' do
      get :show, uuid: 9999, locale: 'en', auth_token: user.auth_token
      expect(response.status).to eq(404)
      expect(response_json['message']).to eq('Not found')
    end
  end

  context 'create' do
    let(:order_params) do
      {
        auth_token: user.auth_token,
        uuid: UUIDTools::UUID.timestamp_create.to_s,
        currency: 'USD',
        coupon: coupon.code.downcase,
        payment_method: 'paypal',
        billing_info: billing_profile_params,
        shipping_info: billing_profile_params,
        order_items: [
          work_uuid: work.uuid,
          quantity: 1
        ]
      }
    end
    let(:user_agent) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3)' }

    it 'status 201 order_items with work_uuid && downcase coupon' do
      @request.env.merge!('HTTP_USER_AGENT' => user_agent)
      post :create, order_params
      expect(response).to be_success
      expect(response.status).to eq(201)
      expect(response_json['order_price']).not_to be nil
      expect(response_json['order_price']['sub_total']).to eq(99.9)
      expect(response_json['order_price']['coupon']).to eq(5)
      expect(response_json['order_price']['shipping_fee']).to eq(0)
      expect(response_json['order_price']['total']).to eq(94.9)
      expect(response_json['billing_info']).not_to be nil
      expect(response_json['shipping_info']).not_to be nil
      expect(response_json['payment']).to eq('paypal')
      expect(response_json['payment_method']).to eq('paypal')

      order_no = response_json['order_no']
      expect(order_no).not_to be nil
      order = Order.find_by(order_no: order_no)
      expect(order.ip).not_to be nil
      expect(order.platform).not_to be nil
      expect(order.user_agent).not_to be nil
    end

    it 'status 400 when order_items with wrong work_uuid' do
      post :create, order_params.merge(order_items: [work_uuid: 99_999, quantity: 1])
      expect(response.status).to eq(400)
      expect(response_json['message']).not_to be nil
    end

    it 'status 400 without order_items' do
      post :create, order_params.merge(order_items: [])
      expect(response.status).to eq(400)
      expect(response_json['error']).to eq('Order Items can\'t be nil')
    end

    it 'don\'t have billing_info' do
      post :create, order_params.merge(billing_info: {})
      expect(response.status).to eq(400)
      expect(response_json['status']).to eq('error')
      expect(response_json['message']).not_to be nil
    end

    it 'creates create activity' do
      expect(controller).to receive(:remote_ip).and_return('127.0.0.1').at_least(:once)
      post :create, order_params
      activity = Order.last.activities.where(key: 'create').first
      expect(activity.user).to eq(user)
      expect(activity.source).to eq('channel' => 'api',
                                    'ip' => '127.0.0.1',
                                    'os_type' => 'Unknown',
                                    'os_version' => 'Unknown',
                                    'user_agent' => 'Rails Testing',
                                    'app_version' => 'Unknown',
                                    'device_model' => 'Unknown')
    end

    context 'validate billinfo email format' do
      it 'failed with wrong format' do
        billing_profile = billing_profile_params
        billing_profile[:email] = 'xxx.xxx.xxx'
        post :create, order_params.merge(billing_info: billing_profile)
        expect(response.status).to eq(400)
        expect(response_json['status']).to eq('error')
        expect(response_json['message']).to include(a_string_matching(/Email/))
      end
    end
  end

  context 'pay' do
    # TO DO Mock paypal request
    let(:stripe_helper) { StripeMock.create_test_helper }
    let(:pay_params) { { order_uuid: order.uuid, auth_token: user.auth_token } }
    before { StripeMock.start }
    after { StripeMock.stop }
    let(:payment_id) { paypal_payment.id }

    before do
      @stripe_token = stripe_helper.generate_card_token
    end

    it 'status 200 by uuid', :vcr do
      patch :pay, pay_params.merge(payment_method: 'paypal', payment_id: payment_id)
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq('paid')
      expect(response_json['order_no']).not_to be_nil
      expect(response_json['payment_info']).not_to be_nil
      expect(order.reload.payment_id).to eq(payment_id)
    end

    it 'status 200 by uuid when stripe works' do
      patch :pay, pay_params.merge(payment_method: 'stripe', payment_id: @stripe_token)
      expect(response.status).to eq(200)
      expect(response_json['order_no']).not_to be_nil
      expect(response_json['payment_info']).not_to be_nil
    end

    it 'order uuid error' do
      patch :pay, pay_params.merge(order_uuid: 999, payment_method: 'paypal', payment_id: 'asdf')
      expect(response.status).to eq(404)
      expect(response_json['error']).to(match('Can\'t find order with uuid'))
    end

    it 'Can\'t find paypal payment.', :vcr do
      order.order_items.create(itemable: create(:work), quantity: 1) # 價格 99.9
      order.save
      patch :pay, pay_params.merge(payment_method: 'paypal', payment_id: 'blah')
      expect(response_json['status']).to eq('Error')
      expect(response_json['message'][0]).to(eq('Can\'t find paypal payment.'))
    end

    it 'uses previous payment method if not given' do
      order.update(payment_method: 'paypal')
      patch :pay, pay_params.merge(payment_id: 'blah')
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq('paid')
      expect(response_json['order_no']).not_to be_nil
    end

    it 'skips pay for non-pending orders' do
      order.reload
      order.payment_method = 'cash_on_delivery'
      order.pay!
      patch :pay, pay_params
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq('paid')
      expect(response_json['order_no']).not_to be_nil
      expect(response_json['payment_info']).not_to be_nil
    end

    it 'payment expire day' do
      order = create(:order, :with_atm, user: user, aasm_state: 'canceled')
      patch :pay, pay_params.merge(order_uuid: order.uuid)
      expect(response.status).to eq(400)
      expect(response_json['code']).to eq('OrderExpireDayAutoCancelError')
    end
  end

  context 'pay zero price' do
    let(:pay_params) do
      {
        payment_method: 'paypal',
        payment_id: 0,
        auth_token: user.auth_token
      }
    end
    it 'success' do
      coupon = create(:coupon, price_table: { 'USD' => 99.9, 'TWD' => 2999 })
      order = create(:order, user: user, coupon: coupon)
      order.reload
      order.save

      patch :pay, pay_params.merge(order_uuid: order.uuid)
      expect(response.status).to eq(200)
      expect(response_json['status']).to eq('paid')
      expect(response_json['order_no']).not_to be_nil
      order.reload
      expect(order.paid?).to be true
    end

    it 'error' do
      coupon = create(:coupon, price_table: { 'USD' => 50 })
      order = create(:order, user: user, coupon: coupon)
      order.reload
      order.save

      patch :pay, pay_params.merge(order_uuid: order.uuid)
      expect(response_json['status']).to eq('Error')
      expect(response_json['message']).not_to be nil
    end

    context 'pay with cash_on_delivery' do
      it 'status 200 ' do
        order = create(:order, payment_method: 'cash_on_delivery')
        patch :pay, order_uuid: order.uuid, auth_token: order.user.auth_token, payment_id: '0'
        expect(response.status).to eq(200)
        expect(response_json['status']).to eq('paid')
        expect(response_json['order_no']).not_to be_nil
      end
    end
  end

  context 'update' do
    let(:order_params) do
      {
        uuid: order.uuid,
        currency: 'TWD',
        coupon: '',
        auth_token: user.auth_token,
        billing_info: billing_profile_params,
        shipping_info: billing_profile_params,
        order_items: [
          work_uuid: work.uuid,
          quantity: 2
        ]
      }
    end
    it 'status 200' do
      allow_any_instance_of(Work).to receive(:price_in_currency).and_return(300)
      allow_any_instance_of(ArchivedWork).to receive(:price_in_currency).and_return(300)
      put :update, order_params
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response_json['currency']).to eq('TWD')
      expect(response_json['price']).to eq(600)
    end

    it 'update price' do
      put :update, order_params.merge(currency: 'USD')
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response_json['currency']).to eq('USD')
    end

    it 'status 404' do
      put :update, order_params.merge(uuid: 9999)
      expect(response.status).to eq(404)
      expect(response_json['status']).to eq('error')
      expect(response_json['message']).to match('Not found')
    end

    context 'update items' do
      it 'replace all items' do
        put :update, order_params.merge(
          currency: 'USD', order_items: [work_uuid: another_work.uuid, quantity: 3]
        )
        expect(order.reload.order_items.count).to eq(1)
        expect(response.body).to eq(Api::My::OrderCreateSerializer.new(order.reload, root: false).to_json)
        price = order.reload.order_items.inject(0) do |sum, item|
          sum + item.price_in_currency(order.reload.currency) * item.quantity
        end.round(2)
        expect(response_json['price']).to eq(price)
      end
    end
  end
end
