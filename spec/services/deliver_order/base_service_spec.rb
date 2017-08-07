require 'spec_helper'

describe DeliverOrder::BaseService do
  Given(:service) { DeliverOrder::BaseService.new }
  Given(:path) { 'path' }
  Given(:body) { 'result' }
  Given(:access_token) { 'access_token' }
  before do
    allow(service).to receive(:access_token).and_return('access_token')
    stub_request(:get, "#{Settings.deliver_order.website}/api/deliver_order/#{path}?access_token=#{access_token}")
      .to_return(status: 200, body: body, headers: {})
    stub_request(:post, "#{Settings.deliver_order.website}/api/deliver_order/#{path}?access_token=#{access_token}")
      .to_return(status: 200, body: body, headers: {})
    stub_request(:put, "#{Settings.deliver_order.website}/api/deliver_order/#{path}?access_token=#{access_token}")
      .to_return(status: 200, body: body, headers: {})
  end

  context '#get' do
    context 'get without block' do
      Then { service.get(path).body == body }
    end

    context 'get with block' do
      Given(:result){ { res: nil } }
      When { service.get(path) { |res| result[:res] = res.body } }
      Then { result[:res] == body }
    end
  end

  context '#post' do
    Then { service.post(path).body == body }
  end

  context '#put' do
    Then { service.put(path).body == body }
  end

  context 'raise error' do
    Given(:authorizer) { DeliverOrder::AuthorizerRedis.new }
    Given(:token) { 'token' }
    before { authorizer.send(:redis_set, token) }

    context '400 error' do
      Given(:path_400) { 'path_400' }
      before do
        stub_request(:get, "#{Settings.deliver_order.website}/api/deliver_order/#{path_400}?access_token=#{access_token}")
          .to_return(status: 400, body: body, headers: {})
      end

      Then { expect { service.get(path_400) }.to raise_error(DeliverOrderError) }
      And { authorizer.redis.get('access_token') == token }
    end

    context '401 error' do
      Given(:path_401) { 'path_401' }
      before do
        stub_request(:get, "#{Settings.deliver_order.website}/api/deliver_order/#{path_401}?access_token=#{access_token}")
          .to_return(status: 401, body: body, headers: {})
      end

      Then { expect { service.get(path_401) }.to raise_error(DeliverOrderError) }
      And { authorizer.redis.get('access_token').nil? }
    end
  end

  context '#errors' do
    before do
      service.errors.add('Error1', 'DeliverOrderError')
      service.errors.add('Error2', 'OtherError')
    end
    Then { expect(service.errors.full_messages).to match_array(['Error1 DeliverOrderError', 'Error2 OtherError']) }
  end
end
