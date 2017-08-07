begin
  $redis = Redis.new(url: Settings.Redis.url)
  $redis.ping
rescue
  raise "please install and start redis, install on MacOSX: 'sudo brew install redis', start : 'redis-server /usr/local/etc/redis.conf'"
end
