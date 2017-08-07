require 'redis-namespace'
require 'i18n/backend/active_record'
redis = Redis.new(url: Settings.Redis.url)

I18n.backend = I18n::Backend::Chain.new(
    I18n::Backend::CachedKeyValueStore.new(
        Redis::Namespace.new(:i18n, redis: redis)
    ),
    I18n.backend
)
