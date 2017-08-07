require 'spec_helper'

RSpec.describe OrderResultsController, type: :controller do
  describe '#show' do
    context 'sign in' do
      before do
        @user = User.new_guest
        @user.save
        sign_in @user
      end

      it 'renders success page if paid' do
        order = create(:order, user: @user).tap(&:pay!)
        get :show, locale: 'zh-TW', id: order.order_no
        expect(response).to render_template(:success)
      end

      it 'renders waiting page if payment method is delayed payment' do
        order = create(:order, payment_method: 'neweb/atm', aasm_state: 'waiting_for_payment', user: @user)
        get :show, locale: 'zh-TW', id: order.order_no
        expect(response).to render_template(:waiting)
      end

      it 'renders failure page if payment method is delayed payment but state is not waiting_for_payment' do
        order = create(:order, payment_method: 'neweb/atm', aasm_state: 'pending', user: @user)
        get :show, locale: 'zh-TW', id: order.order_no
        expect(response).to render_template(:failure)
      end

      it 'renders failure page if payment method is neweb_mpp' do
        order = create(:order, payment_method: 'neweb_mpp', user: @user)
        order.activities.create!(key: 'pay_fail', extra_info: { 'BankResponseCode': 'fail' })
        get :show, locale: 'zh-TW', id: order.order_no
        expect(response).to render_template(:failure)
      end

      it 'renders failure page if not paid' do
        order = create(:order, user: @user)
        get :show, locale: 'zh-TW', id: order.order_no
        expect(response).to render_template(:failure)
      end

      it 'not current user' do
        order = create(:order).tap(&:pay!)
        get :show, locale: 'zh-TW', id: order.order_no
        expect(response.status).to eq(404)
      end
    end

    context 'not sign in' do
      it '404 not found' do
        order = create(:order)
        get :show, locale: 'zh-TW', id: order.order_no
        expect(response.status).to eq(404)
      end
    end
  end
end
