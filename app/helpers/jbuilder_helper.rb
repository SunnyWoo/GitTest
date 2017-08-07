module JbuilderHelper
  # check the object can be cached or not (not persisted, is nil, cannot generate cache key, ...)
  #
  # example:
  #
  #     cache_json_for(json, user) do
  #       ...
  #     end
  #
  #     cache_json_for(json, user, ['v1', user]) do
  #       ...
  #     end
  def cache_json_for(json, object, key = object, &block)
    return block.call if object.nil? || !object.persisted?
    cache_key = ActiveSupport::Cache.expand_cache_key(key)
    json.cache!([cache_key], &block)
  rescue
    block.call
  end

  def full_translations(translations)
    default_translations.merge(translations)
  end

  def default_translations
    I18n.available_locales.each_with_object({}) do |locale, hash|
      hash[locale.to_s] = ''
    end
  end
end
