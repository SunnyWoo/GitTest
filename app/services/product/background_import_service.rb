class Product::BackgroundImportService
  attr_accessor :json, :email, :redis_key

  def initialize(args = {})
    @json = args.delete(:json)
    @email = args.delete(:email)
    @redis_key ||= "import_product_json:#{Time.zone.now.strftime('%Y%m:%d%H%M%S%L')}"
  end

  def execute
    set_to_redis
    ImportProductWorker.perform_async(@redis_key)
  end

  private

  def set_to_redis
    validate
    $redis.set("#{@redis_key}:json", @json)
    $redis.set("#{@redis_key}:email", @email)
  end

  def validate
    fail ApplicationError, "json can't be nil" unless @json.present?
    fail ApplicationError, "email can't be nil" unless @email.present?
  end
end
