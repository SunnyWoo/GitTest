class ImportProductWorker
  include Rails.application.routes.url_helpers
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(redis_key)
    service = Product::ImportService.new($redis.get("#{redis_key}:json"))
    service.execute
    $redis.set("#{redis_key}:logs", service.logs.to_json)
    expire_redis_data(redis_key)
    email = $redis.get("#{redis_key}:email")
    title = 'Import ProductModel Finish'
    ApplicationMailer.notice_admin(email, title, message(redis_key)).deliver
  end

  private

  def message(key)
    url = import_admin_product_models_url(key: key, host: Settings.api_host)
    msg = "請到下列網址查看 log\n"
    msg + "<a href='#{url}'>#{url}</a>"
  end

  # 設定相關資料一個月後清除
  def expire_redis_data(redis_key)
    $redis.expire("#{redis_key}:json", 1.month)
    $redis.expire("#{redis_key}:email", 1.month)
    $redis.expire("#{redis_key}:logs", 1.month)
  end
end
