require 'rails_helper'
require 'stripe_mock'

RSpec.describe Payment::StripeController, :type => :controller do
  before do
    sign_in create(:user)
  end

  describe '#begin', :vcr do
    context 'when not provides order_no' do
      it 'creates order from session and redirect to Stripe' do
        CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
        post :begin, {locale: 'zh-TW'}, { cart: cart_session }
        order = Order.last
        expect(order).to be_pending
        expect(order.payment_id).to be_nil
        expect(response.status).to eq(200)
      end
    end

    context 'when provides order_no' do
      context 'and order is pending' do
        it 'pays the order and redirect to finish path' do
          order = create(:pending_order, :priced, payment_method: 'stripe')
          post :begin, locale: 'zh-TW', order_no: order.order_no
          expect(order.reload).to be_pending
          expect(order.payment_id).to be_nil
          expect(response.status).to eq(200)
        end
      end

      context 'and order is not pending' do
        it 'raises not found' do
          order = create(:paid_order, payment_method: 'stripe')
          post :begin, locale: 'zh-TW', order_no: order.order_no
          expect(response.status).to eq(404)
        end
      end

      context 'and order is not found' do
        it 'raises not found' do
          post :begin, locale: 'zh-TW', order_no: 'nothisorderno'
          expect(response.status).to eq(404)
        end
      end
    end

    context 'free checking' do
      it 'with coupon discount all order price' do
        post :begin, {locale: 'zh-TW'}, { cart: cart_session_for_free_checking }
        order = Order.last
        expect(order).to be_paid
        expect(response.session['cart']).to be nil
        expect(response).to redirect_to(order_result_path(order.order_no))
      end
    end
  end

  describe '#callback', :vcr do
    before do
      CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
      CurrencyType.create(name: 'TWD', code: 'TWD', rate: 1)
    end

    let(:stripe_helper) { StripeMock.create_test_helper }
    before { StripeMock.start }
    after { StripeMock.stop }
    let(:order) {
      post :begin, {locale: 'zh-TW'}, { cart: cart_session }
      Order.last
    }

    context 'when charge is success' do
      it 'pays the order and redirect to finish path' do
        fake_token = stripe_helper.generate_card_token
        post :callback, locale: 'zh-TW', order_no: order.order_no, order: { stripe_card_token: fake_token }
        order.reload
        charge = Stripe::Charge.retrieve(order.payment_id)
        expect(order).to be_paid
        expect(charge.paid).to eq(true)
        expect(charge.id).to eq(order.payment_id)
        expect(charge.receipt_email).to eq('noel.chen@rspectest.me')
        expect(response).to redirect_to(finish_payment_stripe_path(order_no: order.order_no))
      end
    end

    context 'when charge is failed' do
      it 'with wrong token' do
        post :callback, locale: 'zh-TW', order_no: order.order_no, order: { stripe_card_token: 'fake_token' }
        expect(response).to be_redirect
        expect(order.activities.where(key: "pay_fail").all).not_to be_empty
      end

      it 'invalid card info' do
        #non
      end
    end
  end

  describe '#finish' do
    it 'redirect to order result page' do
      order = create(:paid_order, payment_method: 'stripe')
      get :finish, locale: 'zh-TW', order_no: order.order_no
      expect(response).to redirect_to(order_result_path(order.order_no))
    end
  end

  def cart_session
    work = create(:work)
    {
      currency: 'USD',
      payment: 'stripe',
      billing_info: {
        country_code: 'TW',
        email: 'noel.chen@rspectest.me',
        phone: '0933444555',
        address: 'Taipei Free Road'
      },
      items: [[work.to_gid.to_s, 1]]
    }
  end

  def cart_session_for_free_checking
    work = create(:work)
    coupon = create(:max_price_coupon)
    {
      currency: 'USD',
      coupon_code: coupon.code,
      payment: 'stripe',
      billing_info: {
        country_code: 'TW',
        email: 'noel.chen@rspectest.me',
        phone: '0933444555',
        address: 'Taipei Free Road'
      },
      items: [[work.to_gid.to_s, 1]]
    }
  end
end
