module WorkSaleCount
  extend ActiveSupport::Concern

  module ClassMethods
    def redis
      @redis ||= Redis::Namespace.new(:work_sale_count, redis: $redis)
    end
  end

  def redis
    self.class.redis
  end

  # 設定販賣數量 與 初始 sale_count 為 0
  def set_sale_count_limit(limit)
    redis.set "uuid:#{uuid}:sale_count_limit", limit
    redis.set "uuid:#{uuid}:sale_count", 0
  end

  def sale_count_limit
    redis.get "uuid:#{uuid}:sale_count_limit"
  end

  # 販賣數量 + 1
  def incr_sale_count
    redis.incr "uuid:#{uuid}:sale_count"
  end

  def sale_count
    redis.get "uuid:#{uuid}:sale_count"
  end
end
