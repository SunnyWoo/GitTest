require 'spec_helper'

RSpec.describe Mobile::RedeemsController, type: :controller do
  context '#create' do
    context 'when the user signs in' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in create(:user)
      end
      Given(:work) { create(:work, :with_iphone6_model) }
      Given(:redeem_work) { create(:work, :redeem) }
      Given(:bdevent) { create(:bdevent) }
      Given(:coupon) { create(:coupon) }
      Given(:redeem_coupon) { create(:coupon, condition: 'simple',
                                              coupon_rules: [create(:bdevent_rule, bdevent_id: bdevent.id)]) }
      Given(:shipping_info_params) do
        {
          name: 'Rey',
          email: 'rey.jedi@commandp.com',
          phone: 218_721_872_187,
          address: 'jabba planet',
          zip_code: 'FN-2187',
          country_code: 'US'
        }
      end

      context 'it redirects_to success with the redeem_order created and the valid redeem_work' do
        Given(:params) do
          {
            work_gid: redeem_work.to_sgid.to_s,
            redeem_code: redeem_coupon.code,
            shipping_info: shipping_info_params,
            locale: 'zh-TW'
          }
        end
        Given do
          session[:bdevent_id] = bdevent.id
          session[:redeem_code] = redeem_coupon.code
        end
        When { post :create, params }
        Then { expect(response).to redirect_to success_mobile_redeems_path }
        Given(:redeem_order) { Order.last }
        And { redeem_order.paid? }
        And { redeem_order.payment == 'redeem' }
        And { redeem_order.order_items.count == 1 }
        And { redeem_order.order_items.first.quantity == 1 }
        And { redeem_order.shipping_info.name == shipping_info_params[:name] }
        And { redeem_order.shipping_info.email == shipping_info_params[:email] }
        And { redeem_order.shipping_info.phone == shipping_info_params[:phone].to_s }
        And { redeem_order.shipping_info.address == shipping_info_params[:address] }
      end

      context 'it renders check_out with the invalid redeem_code' do
        Given(:params) do
          {
            work_gid: redeem_work.to_sgid.to_s,
            redeem_code: coupon.code,
            shipping_info: shipping_info_params,
            locale: 'zh-TW'
          }
        end
        Given do
          session[:bdevent_id] = bdevent.id
          session[:redeem_code] = coupon.code
        end
        Given!(:order_count) { Order.count }
        When { post :create, params }
        Then { expect(response).to render_template :check_out }
        And { Order.count == order_count }
      end

      context 'it redirects_to success with the redeem_order created and the valid redeem product' do
        Given(:params) do
          {
            work_gid: work.to_sgid.to_s,
            redeem_code: redeem_coupon.code,
            shipping_info: shipping_info_params,
            locale: 'zh-TW'
          }
        end
        Given do
          session[:bdevent_id] = bdevent.id
          session[:redeem_code] = redeem_coupon.code
        end
        Given!(:order_count) { Order.count }
        When { post :create, params }
        Then { expect(response).to redirect_to success_mobile_redeems_path }
        And { Order.count == (order_count + 1) }
      end

      context 'render 404 when session redeem_code is nil' do
        Given(:params) do
          {
            work_gid: work.to_sgid.to_s,
            redeem_code: redeem_coupon.code,
            shipping_info: shipping_info_params,
            locale: 'zh-TW'
          }
        end
        When { post :create, params }
        Then { response.code.to_i == 404 }
      end
    end

    context 'when there is no user signed in' do
      Given(:redeem_work) { create(:work, :redeem) }
      Given(:redeem_coupon) { create(:coupon, work_gids: [redeem_work.to_gid_param]) }
      Given(:shipping_info_params) do
        {
          name: 'Rey',
          email: 'rey.jedi@commandp.com',
          phone: 218_721_872_187,
          address: 'jabba planet',
          zip_code: 'FN-2187',
          country_code: 'US'
        }
      end
      context 'it redirects_to success with the redeem_order created and the valid redeem_work' do
        Given(:params) do
          {
            work_gid: redeem_work.to_sgid.to_s,
            redeem_code: redeem_coupon.code,
            shipping_info: shipping_info_params,
            locale: 'zh-TW'
          }
        end
        When { post :create, params }
        Then { response.status == 404 }
      end
    end
  end

  context '#success' do
    When { get :success, locale: :'zh-TW' }
    Then { response.status == 200 }
    Then { expect(response).to render_template(:success) }
  end
end
