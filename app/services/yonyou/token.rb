class Yonyou::Token
  attr_accessor :url, :app_secret
  EXPIRE_SECONDS = 6000 # 平台的过期时间是 7200 秒

  class << self
    def redis
      server = Redis.new(url: Settings.Redis.url)
      @redis ||= Redis::Namespace.new(:yonyouup, redis: server)
    end
  end

  def initialize
    @url = 'https://api.yonyouup.com/system/token'
    @app_secret = Settings.yonyou.app_secret
  end

  def token
    redis.get('token') || retrieve_token
  end

  private

  def redis
    self.class.redis
  end

  def request
    @request ||= Yonyou::Request.new
  end

  def get
    request.get('https://api.yonyouup.com/system/token', app_secret: app_secret)
  end

  def new_token
    @token ||= get.token.id
  end

  def retrieve_token
    redis.set('token', new_token, ex: EXPIRE_SECONDS)
    new_token
  end
end
