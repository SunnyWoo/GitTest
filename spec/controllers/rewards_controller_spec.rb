require 'rails_helper'

describe RewardsController, type: :controller do
  Given(:reward) { create :reward }
  Given(:another_reward) { create :reward }
  context '#validate' do
    context 'returns 200 when reward match' do
      When { patch :validate, order_no: reward.order_no, phone: reward.order.billing_info_phone }
      Then { response.status == 200 }
    end

    context 'returns 404 when reward inexistent' do
      When { patch :validate, order_no: '1234', phone: reward.order.billing_info_phone }
      Then { response.status == 404 }
    end

    context 'returns 404 when reward phone is wrong' do
      When { patch :validate, order_no: reward.order_no, phone: '1234' }
      Then { response.status == 404 }
    end
  end

  context '#show' do
    context 'redirects to share with reward not found' do
      When { post :show, id: reward, order_no: reward.order_no, phone: '1234', locale: 'en' }
      Then { expect(response).to redirect_to(reward_share_path(reward)) }
      And { session[:reward_validation].nil? }
    end

    context 'redirects to roo_path without reward nor id' do
      When { post :show, id: '', locale: 'en' }
      Then { expect(response).to redirect_to(root_path) }
      And { session[:reward_validation].nil? }
    end

    context 'render 200 with reward found' do
      When { post :show, id: reward, order_no: reward.order_no, phone: reward.phone, locale: 'en' }
      Then { response.status == 200 }
      And { session[:reward_validation].to_a.include? Digest::MD5.hexdigest(reward.order_no + reward.phone) }
    end

    context 'render 200 with session reward_validation existient as well as other reward provided' do
      before { session[:reward_validation] = [Digest::MD5.hexdigest(reward.order_no + reward.phone)] }
      When { post :show, id: another_reward, order_no: another_reward.order_no, phone: another_reward.phone, locale: 'en' }
      Then { response.status == 200 }
      And { session[:reward_validation].to_a.include? Digest::MD5.hexdigest(another_reward.order_no + another_reward.phone) }
    end
  end

  context '#share' do
    context 'render share without session reward_validation' do
      When { get :share, id: reward, locale: 'en' }
      Then { expect(response).to render_template(:share) }
    end

    context 'render show with session reward_validation' do
      before { session[:reward_validation] = [Digest::MD5.hexdigest(reward.order_no + reward.phone)] }
      When { get :share, id: reward, locale: 'en' }
      Then { expect(response).to render_template(:share) }
    end

    context 'render share with session reward_validation not eligible' do
      before { session[:reward_validation] = [Digest::MD5.hexdigest(reward.order_no + reward.phone)] }
      When { get :share, id: another_reward, locale: 'en' }
      Then { expect(response).to render_template(:share) }
    end
  end
end
