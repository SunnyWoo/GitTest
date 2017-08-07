require 'redis-namespace'
require 'csvify'
include Csvify

class I18nBackendService
  def self.save_from_yml_to_redis(path = "config/locales")
    Dir.chdir(path) do
      Dir.glob(File.join("**", "*.yml")).each do |file|
        yml_data = YAML.load_file(file)
        data = {}
        visit(data, yml_data)
        data.each do |key, value|
          key = key.sub('.', '')
          # 這幾種格式的i18n在yml裡是存成hash或陣列的，目前我們redis還無法支援這種格式，所以就先不存進db改load yml！
          next if %w(date datetime number time).include? key.split('.')[1]
          next if value.nil?
          translator = Translator.new(key)
          translator.value = value
          translator.redis_key = key
          translator.save_by_redis!
        end
      end
    end
  end

  def self.delete_i18n_from_redis
    keys = $redis.keys("i18n:*")
    $redis.del(keys)
  end

  def self.save_from_redis_to_db
    # Redis裡的key   會長成：  "i18n:en.editor.upload_photo.li4"  i18n是namespace, en是locale, editor.upload_photo.li4才是key
    # Redis裡的value 會長成：  "\"Your own original art, illustration or photograph!\""
    # 所以要做些字串處理再存到db裡
    redis = Redis::Namespace.new(:i18n, redis: $redis)
    keys = redis.keys
    keys.each do |key|
      value = redis.get key
      locale = key.split('.')[0]
      next if locale.blank? || I18n.available_locales.map(&:to_s).exclude?(locale)
      key = key.split(locale)[1].sub('.', '')
      value = (["\'", "\""].include? value[0] && value[-1]) ? value[1..-2] : value
      t = Translation.find_or_initialize_by(locale: locale, key: key)
      t.value = value
      t.save!
    end
  end
end
