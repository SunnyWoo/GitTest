module Cacheable
  extend ActiveSupport::Concern
  included do
    cached
  end

  def cache_key
    [I18n.locale, object.id, object.updated_at, *extra_cache_key]
  end

  def extra_cache_key
  end
end
