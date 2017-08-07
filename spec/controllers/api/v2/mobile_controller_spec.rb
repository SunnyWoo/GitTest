require 'spec_helper'

describe Api::V2::MobileController, type: :controller do
  before { @request.env.merge! api_header(2) }
  Given(:mobile) { '18516101494' }
  Given(:msg) { 'Verification code is sent.' }

  describe 'GET code' do
    Given(:registered_mobile) { '18516101000' }
    Given(:unregistered_mobile) { '18612341234' }
    before { create :user, mobile: registered_mobile }
    context 'fail when mobile is not valid' do
      When { get :code }
      it_behaves_like 'apiError', 400, 'MobileNumberError'
    end

    context 'fail when mobile is registered' do
      When { get :code, mobile: registered_mobile }
      it_behaves_like 'apiError', 400, 'MobileRegisteredError', 'The phone is registered'
    end

    context 'success when usage register' do
      Given(:expire_in) { rand(MobileVerifyService::EXPIRE_SECONDS) }
      Given(:service) do
        instance_spy('MobileVerifyService', send_code: true, retrieve_code: '134557', expire_in: expire_in)
      end
      before { allow(MobileVerifyService).to receive(:new).and_return(service) }
      When { get :code, mobile: unregistered_mobile, usage: 'register' }
      Then { response.status == 200 }
      And { response_json['data']['msg'] == msg }
      And { response_json['data']['code'] == '134557' }
      And { response_json['data']['expire_in'] == expire_in }
      And { expect(service).to have_received(:retrieve_code) }
      And { expect(service).to have_received(:send_code) }
    end
  end

  describe 'POST verify' do
    context 'code error' do
      Given(:failed_code) { 'failed_code' }
      When { post :verify, mobile: mobile, code: failed_code }
      Then { response.status == 200 }
      And { response_json['data']['verified'] == false }
    end

    context 'code true' do
      Given(:success_code) { 'success_code' }
      Given(:service) { instance_spy('MobileVerifyService', verify: true) }
      before { allow(MobileVerifyService).to receive(:new).and_return(service) }
      When { post :verify, mobile: mobile, code: success_code }
      Then { response.status == 200 }
      And { response_json['data']['verified'] == true }
    end
  end

  describe 'GET forget_password' do
    context 'should receive mobile parameter' do
      When { get :forget_password }
      it_behaves_like 'apiError', 400, 'MobileNumberError'
    end

    context 'No such user with this mobile' do
      When { get :forget_password, mobile: '1419132314' }
      it_behaves_like 'apiError', 404, 'RecordNotFoundError'
    end

    context 'status ok' do
      Given(:expire_in) { rand(MobileVerifyService::EXPIRE_SECONDS) }
      Given(:service) do
        instance_spy('MobileVerifyService',
                     mobile: mobile, retrieve_code: '134557',
                     send_code: true, expire_in: expire_in)
      end
      before { allow(MobileVerifyService).to receive(:new).and_return(service) }
      Given!(:user) { create(:user, mobile: mobile) }
      When { get :forget_password, mobile: mobile }
      Then { response.status == 200 }
      And { expect(service).to have_received(:retrieve_code) }
      And { expect(service).to have_received(:send_code) }
    end
  end

  describe 'POST reset_password' do
    Given(:service) { instance_spy('MobileVerifyService', verify: true, mobile: mobile) }

    context 'should receive mobile parameter' do
      When { post :reset_password }
      it_behaves_like 'apiError', 400, 'MobileNumberError'
    end

    context 'should verify the code' do
      When { post :reset_password, mobile: mobile }
      it_behaves_like 'apiError', 401, 'MobileVerificationFailedError'
    end

    context 'no such user with this mobile' do
      before { allow(MobileVerifyService).to receive(:new).and_return(service) }
      When { post :reset_password, mobile: mobile }
      it_behaves_like 'apiError', 404, 'RecordNotFoundError'
    end

    context 'password parameter needed' do
      Given!(:user) { create(:user, mobile: mobile) }
      before { allow(MobileVerifyService).to receive(:new).and_return(service) }
      When { post :reset_password, mobile: mobile }
      it_behaves_like 'apiError', 400, 'ParametersInvalidError',
                      'Invalid parameter password'
    end

    context 'password confirmation failed' do
      Given!(:user) { create(:user, mobile: mobile) }
      before { allow(MobileVerifyService).to receive(:new).and_return(service) }
      When { post :reset_password, mobile: mobile, password: 'commandp', password_confirmation: 'commandpp' }
      it_behaves_like 'apiError', 422, 'RecordInvalidError'
    end

    context 'all success, password changed.' do
      Given!(:user) { create(:user, mobile: mobile) }
      before { allow(MobileVerifyService).to receive(:new).and_return(service) }
      When { post :reset_password, mobile: mobile, password: 'commandp', password_confirmation: 'commandp' }
      Then { response.status == 200 }
      And { response_json['data']['msg'] == 'Password changed' }
      And { user.reload.valid_password?('commandp') }
    end
  end
end
