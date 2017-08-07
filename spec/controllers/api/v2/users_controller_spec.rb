require 'spec_helper'

describe Api::V2::UsersController, type: :controller do
  before { @request.env.merge! api_header(2) }
  let(:user) { create(:user) }
  describe '#show' do
    it 'get status 200' do
      get :show, auth_token: user.auth_token
      expect(response.body).to eq(UserSerializer.new(user).to_json)
    end
  end

  describe 'POST #merge' do
    Given!(:to_user) { create(:user) }

    context '404 when no to_user found' do
      When { post :merge, auth_token: user.auth_token }
      it_behaves_like 'apiError', 404, 'RecordNotFoundError'
    end

    context 'success' do
      When { post :merge, auth_token: user.auth_token, to_user_token: to_user.auth_token }
      Then { response.status == 200 }
      And { response_json['user']['user_id'] == to_user.id }
      And { user.reload.role == 'die' }
    end
  end

  describe 'POST bind_mobile' do
    Given(:mobile) { '18516101494' }
    context 'code error' do
      Given(:failed_code) { 'failed_code' }
      When { post :bind_mobile, auth_token: user.auth_token, mobile: mobile, code: failed_code }
      it_behaves_like 'apiError', 401, 'MobileVerificationFailedError'
    end

    context 'code valid' do
      Given(:code) { '142345' }
      Given(:service) { instance_spy('MobileVerifyService', verify: true, mobile: mobile) }
      before { allow(MobileVerifyService).to receive(:new).and_return(service) }
      When { post :bind_mobile, auth_token: user.auth_token, mobile: mobile, code: code }
      Then { response.status == 200 }
      And { user.reload.mobile == mobile }
    end
  end
end
