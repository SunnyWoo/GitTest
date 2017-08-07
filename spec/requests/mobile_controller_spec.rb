require 'spec_helper'

RSpec.describe MobileController, :vcr, type: :request do
  describe '#code' do
    context 'mobile is not invalid' do
      it 'returns 400' do
        allow_any_instance_of(MobileVerifyService).to receive(:random_code).and_return('1234567')
        get mobile_code_path(mobile: '123456789012', locale: 'zh-CN', format: :json)
        expect(response.status).to eq(400)
      end
    end

    context 'mobile valid' do
      Given(:expire_in) { rand(MobileVerifyService::EXPIRE_SECONDS) }
      Given(:service) do
        instance_spy('MobileVerifyService', retrieve_code: '134557', send_code: true, expire_in: expire_in)
      end
      before { allow(MobileVerifyService).to receive(:new).and_return(service) }
      When { get mobile_code_path(mobile: '12345678901', locale: 'zh-CN', format: :json) }
      Then { response.status == 200 }
      And { response_json['success'] }
    end
  end
end
