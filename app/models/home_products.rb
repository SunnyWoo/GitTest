require 'redis-namespace'

class HomeProducts
  def self.redis
    @redis ||= Redis::Namespace.new(:home_products, redis: $redis)
  end

  def self.ids
    if !redis.exists('ids') || redis.type('ids') != 'list'
      Work.featured.pluck(:id)
    else
      redis.lrange('ids', 0, -1)
    end
  end

  def self.ids=(ids)
    redis.del('ids')
    ids.each { |id| redis.rpush('ids', id) }
  end

  def self.scope
    ids.map { |id| Work.find_by(id: id) }.compact
  end
end
