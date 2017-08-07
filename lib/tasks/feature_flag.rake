namespace :feature_flag do
  task remove_campagin_head_flag: :environment do
    redis = Redis::Namespace.new(:feature_flag, redis: $redis)
    FeatureFlag::Feature.features.each do |key|
      redis.srem('features', key) if key =~ /head/
    end
  end
end
