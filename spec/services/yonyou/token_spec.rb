require 'spec_helper'

describe Yonyou::Token do
  Given(:token) { Yonyou::Token.new }

  context '#token' do
    context 'when token is not cached' do
      Given(:response) do
        {
          'errcode' => 0,
          'errmsg' => "成功",
          "token" => {
            "appKey" => "opadef4a423cb622c51",
            "expiresIn" => 7200,
            "id" => "282d2575cd6d4655be2c6096c7e9c657"
          }
        }
      end
      Given(:hashie_res) { Hashie::Mash.new response }
      before { allow(token).to receive(:get).and_return(hashie_res) }
      Then { token.token == '282d2575cd6d4655be2c6096c7e9c657' }
      Given(:token_redis) { token.send(:redis) }
      And { token_redis.get('token') == '282d2575cd6d4655be2c6096c7e9c657' }
    end

    context 'when token is cached' do
      Given(:token_redis) { token.send(:redis) }
      before { token_redis.set('token', '282d2575cd6d4655be2c6096c7e9c657') }
      Then { token.token == '282d2575cd6d4655be2c6096c7e9c657' }
    end
  end
end
