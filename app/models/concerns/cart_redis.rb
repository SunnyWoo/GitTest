module CartRedis
  extend ActiveSupport::Concern

  module ClassMethods
    def redis
      @redis ||= Redis::Namespace.new(:cart_redis, redis: $redis)
    end
  end

  def redis
    self.class.redis
  end

  def redis_set(value)
    return if redis_key.nil? || value.nil?
    redis.setex redis_key, 35.days, value.to_json
  end

  def redis_get
    return if redis_key.nil?
    value = redis.get redis_key
    JSON.parse(value, symbolize_names: true) if value.present? && value != 'null'
  end

  def redis_del
    return if redis_key.nil?
    redis.del redis_key
  end

  def redis_key
    return nil if user_id.nil?
    tmp = ['user_id', user_id]
    tmp << store_id if store_id.present?
    tmp.join(':')
  end
end
