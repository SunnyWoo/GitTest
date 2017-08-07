class InstagramMedia
  EXPIRED_SECONDS = 3_600
  IMAGE_REGEX = %r{display_src\": \"(https?:\/\/(?:www\.|(?!www))[^\s\.]+\.[^\s]{2,}|www\.[^\s]+\.[^\s]{2,})\"}

  attr_accessor :url
  attr_reader :redis_key

  delegate :redis, to: :class

  def self.redis
    @redis or begin
      @redis = Redis::Namespace.new(:instagram, redis: $redis)
    end
  end

  def initialize(hashtag:)
    @url = "https://www.instagram.com/explore/tags/#{hashtag}/"
    hashtag = hashtag.delete(' ').underscore
    @redis_key = "hashtag_#{hashtag}_image_urls"
  end

  def get
    fetch if redis.lrange(redis_key, 0, 5).empty?
    redis.lrange(redis_key, 0, 5)
  end

  protected

  def fetch
    page = HTTParty.get(url)
    body = Nokogiri::HTML.parse(page.body, nil, 'utf-8').text
    images = body.scan(IMAGE_REGEX).map{ |s| s[0] }
    images[0..5].each { |img| redis.rpush(redis_key, img) }
    redis.expire redis_key, EXPIRED_SECONDS
  end
end
