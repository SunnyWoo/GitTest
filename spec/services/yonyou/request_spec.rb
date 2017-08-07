require 'spec_helper'

describe Yonyou::Request do
  Given(:request) { Yonyou::Request.new }

  context '#wrap_get_response' do
    context 'success' do
      Given(:response) do
        {
          'errcode' => 0,
          'errmsg' => '成功',
          'token' => {
            'appKey' => 'opadef4a423cb622c51',
            'expiresIn' => 7200,
            'id' => '282d2575cd6d4655be2c6096c7e9c657'
          }
        }
      end
      Given(:result) { request.send(:wrap_get_response, response) }
      Then { result.token.id == '282d2575cd6d4655be2c6096c7e9c657' }
    end

    Given(:response) do
      {
        'errcode' => 20_001,
        'errmsg' => '客户端未登录',
      }
    end
    Then { expect { request.send(:wrap_get_response, response) }.to raise_error(YonyouError) }
  end

  context '#wrap_post_response' do
    context 'success' do
      Given(:response) do
        {
          'ping_after' => 3,
          'tradeid' => '5f4f1fb7f10411e5b65002004c4f4f50',
          'url' => 'https://api.yonyouup.com:443/result?requestid=5f4f1fb7f10411e5b65002004c4f4f50'
        }
      end
      Given(:result) { request.send(:wrap_post_response, response) }
      Then { result.tradeid == '5f4f1fb7f10411e5b65002004c4f4f50' }
    end

    Given(:response) do
      {
        'errcode' => 20_001,
        'errmsg' => '客户端未登录',
      }
    end
    Then { expect { request.send(:wrap_post_response, response) }.to raise_error(YonyouError) }
  end
end
