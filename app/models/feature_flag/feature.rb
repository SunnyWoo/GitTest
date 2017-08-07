require 'redis-namespace'

class FeatureFlag::Feature
  def self.redis
    @redis ||= Redis::Namespace.new(:feature_flag, redis: $redis)
  end

  def self.features
    redis.smembers('features')
  end

  def self.add_feature(name)
    redis.sadd('features', name)
  end

  delegate :redis, :features, :add_feature, to: :class

  attr_reader :name, :controller

  def initialize(name, controller)
    @name = name
    @controller = controller

    add_feature(name)
  end

  %w(admin user factory).each do |role|
    define_method :"enable_for_#{role}?" do
      redis.get("enable_#{name}_for_#{role}") == '1'
    end

    define_method :"enable_for_#{role}!" do
      redis.set("enable_#{name}_for_#{role}", '1')
    end

    define_method :"disable_for_#{role}!" do
      redis.del("enable_#{name}_for_#{role}")
    end
  end

  def determine
    yield if enable_for_current_session?
  end

  def enable_for_current_session?
    %w(admin user factory).any? do |role|
      send("enable_for_#{role}?") && send("#{role}_session?")
    end
  end

  def admin_session?
    controller.admin_signed_in?
  end

  def user_session?
    true
  end

  def factory_session?
    controller.factory_member_signed_in?
  end
end
