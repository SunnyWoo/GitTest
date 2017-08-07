require 'spec_helper'

describe DeliverOrder::AuthorizerRedis do
  context '#retrieve_access_token' do
    Given(:authorizer) { DeliverOrder::AuthorizerRedis.new }
    Given(:token) { '270156d97689dd5c6974e74fcc3ca1a99b5396c8be59b9daa461ffcd62953500' }

    context 'get token from redis' do
      Given(:authorizer) { DeliverOrder::AuthorizerRedis.new }
      Given(:token) { '270156d97689dd5c6974e74fcc3ca1a99b5396c8be59b9daa461ffcd62953500' }
      When { authorizer.send(:redis_set, token) }
      Then { authorizer.retrieve_access_token == token }
    end

    context 'get token from request' do
      before do
        allow(authorizer).to receive(:access_token).and_return(token)
      end
      Then { authorizer.retrieve_access_token == token }
    end
  end

  context '#redis_del' do
    Given(:authorizer) { DeliverOrder::AuthorizerRedis.new }
    Given(:token) { '270156d97689dd5c6974e74fcc3ca1a99b5396c8be59b9daa461ffcd62953500' }
    When { authorizer.send(:redis_set, token) }
    Then { authorizer.retrieve_access_token == token }
    context 'when redis_del' do
      before do
        allow(authorizer).to receive(:access_token).and_return(nil)
      end
      When { authorizer.redis_del }
      Then { authorizer.retrieve_access_token.nil? }
    end
  end
end
