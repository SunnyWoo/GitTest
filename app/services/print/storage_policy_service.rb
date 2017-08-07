class Print::StoragePolicyService
  class << self
    def redis
      server = Redis.new(url: Settings.Redis.url)
      @redis ||= Redis::Namespace.new(:storage_policy, redis: server)
    end

    def start_adjust
      storage_lock!(true)
    end

    def finish_adjust
      storage_lock!(false)
    end

    def storage_lock?
      redis.get('storage_lock').to_b
    end

    def storage_lock!(boolean)
      redis.set('storage_lock', boolean)
    end
  end
end
