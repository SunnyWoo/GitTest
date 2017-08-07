class DeliverOrder::AuthorizerRedis
  attr_reader :website, :client_id, :secret, :headers

  class << self
    def redis
      server = Redis.new(url: Settings.Redis.url)
      @redis ||= Redis::Namespace.new(:deliver_order, redis: server)
    end
  end

  def redis
    self.class.redis
  end

  def initialize
    @website = Settings.deliver_order.website
    @client_id = Settings.deliver_order.client_id
    @secret = Settings.deliver_order.client_secret
    @headers = { 'Accept' => 'application/vnd.commandp.v3+json' }
  end

  def retrieve_access_token
    redis.get('access_token') || access_token
  end

  def redis_del
    redis.del 'access_token'
  end

  private

  def access_token
    authorize = HTTParty.post("#{website}/oauth/token", headers: headers,
                                                        query: { grant_type: 'client_credentials', scope: 'public',
                                                                 client_id: client_id, client_secret: secret })
    redis_set(authorize['access_token'])
    authorize['access_token']
  end

  def redis_set(value)
    return if value.blank?
    redis.set('access_token', value)
  end
end
