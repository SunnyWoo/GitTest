require 'spec_helper'

RSpec.describe Api::V3::UsersController, :api_v3, type: :controller do
  Given!(:application) { create(:application) }

  describe 'GET /users/:id', signed_in: :normal do
    context 'returns correct user info' do
      Given(:user) { create :user }
      When { get :show, id: user.id, access_token: access_token }
      Then { response.status == 200 }
      And { expect(response).to render_template(:show) }
    end

    context 'returns correct user info with client_id and client_secret in header' do
      before do
        request.headers['ClientId'] = application.uid
        request.headers['ClientSecret'] = application.secret
      end
      Given(:user) { create :user }
      When { get :show, id: user.id }
      Then { response.status == 200 }
      And { expect(response).to render_template(:show) }
    end

    context 'returns 401 when user without access_token and client info in header' do
      When { get :show, id: 'wtf' }
      Then { response.status == 401 }
    end

    context 'returns 401 when user with error access_token and client info in header' do
      before do
        request.headers['ClientId'] = 'error'
        request.headers['ClientSecret'] = 'error'
      end
      When { get :show, id: 'wtf' }
      Then { response.status == 401 }
    end

    context 'returns 404 when user is inexistence' do
      When { get :show, id: 'wtf', access_token: access_token }
      Then { response.status == 404 }
    end
  end

  context 'POST bind_mobile', signed_in: :normal do
    Given(:mobile) { '18516101494' }
    context 'code error' do
      Given(:failed_code) { 'failed_code' }
      When { post :bind_mobile, access_token: access_token, mobile: mobile, code: failed_code }
      it_behaves_like 'apiError', 401, 'MobileVerificationFailedError'
    end

    context 'code valid' do
      Given(:code) { '142345' }
      Given(:service) { instance_spy('MobileVerifyService', verify: true, mobile: mobile) }
      before { allow(MobileVerifyService).to receive(:new).and_return(service) }
      When { post :bind_mobile, access_token: access_token, mobile: mobile, code: code }
      Then { response.status == 200 }
      And { user.mobile != mobile }
      And { user.reload.mobile == mobile }
      And { expect(response).to render_template(:show) }
    end

    context 'return 403 when code is valid and with client_id and client_secret in header' do
      before do
        request.headers['ClientId'] = application.uid
        request.headers['ClientSecret'] = application.secret
      end
      Given(:code) { '142345' }
      Given(:service) { instance_spy('MobileVerifyService', verify: true, mobile: mobile) }
      before { allow(MobileVerifyService).to receive(:new).and_return(service) }
      When { post :bind_mobile, mobile: mobile, code: code }
      Then { response.status == 403 }
    end

    context 'POST bind_mobile', signed_in: false do
      context 'return 403 when signed in :false' do
        Given(:code) { '142345' }
        Given(:service) { instance_spy('MobileVerifyService', verify: true, mobile: mobile) }
        before { allow(MobileVerifyService).to receive(:new).and_return(service) }
        When { post :bind_mobile, access_token: access_token, mobile: mobile, code: code }
        Then { response.status == 403 }
      end

      context 'return 403 with client_id and client_secret in header' do
        before do
          request.headers['ClientId'] = application.uid
          request.headers['ClientSecret'] = application.secret
        end
        Given(:code) { '142345' }
        Given(:service) { instance_spy('MobileVerifyService', verify: true, mobile: mobile) }
        before { allow(MobileVerifyService).to receive(:new).and_return(service) }
        When { post :bind_mobile, mobile: mobile, code: code }
        Then { response.status == 403 }
      end

      context 'return 401 with error client_id and client_secret in header' do
        before do
          request.headers['ClientId'] = 'error'
          request.headers['ClientSecret'] = 'error'
        end
        Given(:code) { '142345' }
        When { post :bind_mobile, access_token: access_token, mobile: mobile, code: code }
        Then { response.status == 401 }
      end
    end
  end
end
