module CacheHelper
  def cache_work(work, &block)
    cache([I18n.locale, work, work.product, Translator.key,
           current_currency_code], &block)
  end

  def cache_key_for_collection(objects)
    Digest::MD5.hexdigest(objects.map(&:cache_key).join)
  end
end
