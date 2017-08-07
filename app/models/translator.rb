require 'redis-namespace'

class Translator
  class InvalidTranslationError < ApplicationError
    def message
      "Redis key and value must be provided!"
    end
  end

  include ActiveModel::Model
  include ActiveModel::Validations
  attr_accessor :value, :key, :locale, :redis_key

  def self.[](key)
    @translators ||= {}
    @translators[key] ||= Translator.new(key)
  end

  def self.redis
    @redis ||= Redis::Namespace.new(:i18n, redis: $redis)
  end

  def self.key
    redis.get "version"
  end

  def self.touch
    redis.incr "version"
  end

  delegate :redis, to: :class

  def initialize(key)
    self.key = key
  end

  def set_redis_key
    self.locale = locale.present? ? locale : I18n.locale
    @redis_key = "#{locale}.#{@key}"
  end

  def redis_value
    @redis_value = value.to_json if value
  end

  def save_by_backend!
    I18n.backend.store_translations(locale, { key => value }, escape: false)
    self.class.touch
  end

  def save_by_redis!
    if redis_key.present? && redis_value.present?
      redis.set redis_key, redis_value
    else
      raise InvalidTranslationError
    end
  end
end
