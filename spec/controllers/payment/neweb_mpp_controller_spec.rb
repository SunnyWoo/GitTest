require 'spec_helper'

RSpec.describe Payment::NewebMppController, :type => :controller do
  before do
    sign_in create(:user)
  end

  describe '#begin', :vcr do
    context 'when not provides order_no' do
      it 'creates order from session and redirect to neweb mpp url' do
        CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
        post :begin, {locale: 'zh-TW'}, { cart: cart_session }
        order = Order.last
        expect(order).to be_pending
        expect(response.status).to eq(302)
      end
    end

    context 'when provides order_no' do
      context 'and order is pending' do
        it 'pays the order and redirect to finish path' do
          order = create(:pending_order, :priced, payment_method: 'neweb_mpp')
          post :begin, locale: 'zh-TW', order_no: order.order_no
          expect(order.reload).to be_pending
          expect(response.status).to eq(302)
        end
      end

      context 'and order is not pending' do
        it 'raises not found' do
          order = create(:paid_order, payment_method: 'neweb_mpp')
          post :begin, locale: 'zh-TW', order_no: order.order_no
          expect(response.status).to eq(404)
        end
      end

      context 'and order is not found' do
        it 'raises not found' do
          post :begin, locale: 'zh-TW', order_no: 'ABCDENDGG'
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
    let(:order) {
      post :begin, {locale: 'zh-TW'}, { cart: cart_session }
      Order.last
    }

    it 'redirects to finish path' do
      CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
      post :callback, locale: 'zh-TW', order_no: order.order_no
      expect(response).to redirect_to(finish_payment_neweb_mpp_url(order_no: order.order_no))
    end
  end

  describe '#finish' do
    it 'redirect to order result page' do
      order = create(:paid_order, payment_method: 'neweb_mpp')
      get :finish, locale: 'zh-TW', order_no: order.order_no
      expect(response).to redirect_to(order_result_path(order.order_no))
    end
  end

  def cart_session
    work = create(:work)
    {
      currency: 'USD',
      payment: 'neweb_mpp',
      billing_info: {
        country_code: 'TW',
        email: 'ayaya@commandp.me',
        phone: '0228825252',
        address: 'Ayaya Home'
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
      payment: 'neweb_mpp',
      billing_info: {
        country_code: 'TW',
        email: 'ayaya@commandp.me',
        phone: '0228825252',
        address: 'Ayaya Home'
      },
      items: [[work.to_gid.to_s, 1]]
    }
  end
end
