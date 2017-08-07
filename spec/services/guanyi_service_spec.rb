require 'spec_helper'

describe GuanyiService do
  Given(:service) { GuanyiService.new }

  context 'fail' do
    context 'appkey错误' do
      Given(:result_body) do
        {
          'success' => false,
          'errorCode' => 'Base Param Error',
          'subErrorCode' => 'ErrorAppKey',
          'errorDesc' => '基本参数错误',
          'subErrorDesc' => 'appkey错误',
          'requestMethod' => nil
        }
      end
      Given(:result) { double(HTTParty::Response, code: 200, body: result_body.to_json) }
      before { expect(service).to receive(:execute).and_return(result) }
      Then { expect { service.request('gy.erp.items.get', page: 1) }.to raise_error(GuanyiError) }
    end
  end
end
