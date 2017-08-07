require 'spec_helper'

describe MobileSendCodeService do
  Given(:mobile) { '18612341234' }
  Given(:expire_in) { rand(MobileVerifyService::EXPIRE_SECONDS) }
  Given(:mobile_verify_service) do
    instance_spy('MobileVerifyService',
                 mobile: mobile, retrieve_code: '134557',
                 send_code: true, expire_in: expire_in)
  end

  before do
    allow(MobileVerifyService).to receive(:new).with(mobile).and_return(mobile_verify_service)
  end

  context '#retrieve_and_send' do
    context 'success when usage is null(default usage is register)' do
      Given(:service) { MobileSendCodeService.new(mobile: mobile) }

      When { service.retrieve_and_send }
      Then { service.code == '134557' }
      And { service.msg == 'Verification code is sent.' }
      And { service.expire_in == expire_in }
    end

    context 'success when usage is register' do
      Given(:service) { MobileSendCodeService.new(mobile: mobile, usage: 'register') }

      When { service.retrieve_and_send }
      Then { service.code == '134557' }
      And { service.msg == 'Verification code is sent.' }
      And { service.expire_in == expire_in }
    end

    context 'fail when usage is register and mobile is registered' do
      When { create :user, mobile: mobile }
      Given(:service) { MobileSendCodeService.new(mobile: mobile, usage: 'register') }

      Then { expect { service.retrieve_and_send }.to raise_error(MobileRegisteredError) }
    end

    context 'success when usage is reset_password' do
      When { create :user, mobile: mobile }
      Given(:service) { MobileSendCodeService.new(mobile: mobile, usage: 'reset_password') }

      When { service.retrieve_and_send }
      Then { service.code == '134557' }
      And { service.msg == 'Verification code is sent.' }
      And { service.expire_in == expire_in }
    end

    context 'fail when usage is reset_password and mobile is unregistered' do
      Given(:service) { MobileSendCodeService.new(mobile: mobile, usage: 'reset_password') }

      Then { expect { service.retrieve_and_send }.to raise_error(MobileUnregisteredError) }
    end

    context 'fail when usage is invalid' do
      Given(:service) { MobileSendCodeService.new(mobile: mobile, usage: 'invalid_usage') }

      Then { expect { service.retrieve_and_send }.to raise_error(ApplicationError) }
    end
  end
end
