class DeliverOrder::BaseService
  extend ActiveModel::Naming
  attr_reader :website, :headers

  def initialize
    @website = Settings.deliver_order.website
    @headers = { 'Accept' => 'application/vnd.commandp.v3+json' }
  end

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end

  def get(path, params = {}, &block)
    call_remote_api(:get, path, params, &block)
  end

  def post(path, params = {}, &block)
    call_remote_api(:post, path, params, &block)
  end

  def put(path, params = {}, &block)
    call_remote_api(:put, path, params, &block)
  end

  def read_attribute_for_validation(attr)
    send(attr)
  end

  def self.human_attribute_name(attr, _options = {})
    attr
  end

  def self.lookup_ancestors
    [self]
  end

  private

  def call_remote_api(method, path, params)
    response = request(method, path, params)
    response_code = response.code.to_i

    redis.redis_del if response_code == 401
    fail DeliverOrderError unless response_code == 200

    if block_given?
      yield(response)
    else
      response
    end
  end

  def request(method, path, params)
    remote_url = "#{website}/api/deliver_order/#{path}?access_token=#{access_token}"
    HTTParty.send(method, remote_url, headers: headers, body: params.as_json)
  end

  def access_token
    redis.retrieve_access_token
  end

  def redis
    @redis ||= DeliverOrder::AuthorizerRedis.new
  end
end
