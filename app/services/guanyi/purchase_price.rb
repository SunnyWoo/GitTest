class Guanyi::PurchasePrice
  include Guanyi::MonthlyOrders

  EXPIRE_SECONDS = '9000'.freeze
  attr_accessor :setting, :categories_sell_count, :rule, :fee

  class << self
    def redis
      server = Redis.new(url: Settings.Redis.url)
      @redis ||= Redis::Namespace.new(:purchase_price, redis: server)
    end
  end

  def redis
    self.class.redis
  end

  def initialize
    @setting = YAML.load(File.read(Rails.root.join('config/guanyi.yml')))['purchase'].with_indifferent_access
    @categories_sell_count = setting['remote_sell_count']
    @rule = setting['rule']
    @fee = setting['fee']
  end

  def price(work)
    category_key = mapping_category_key(work)
    collect_categories_price if redis.get(category_key).blank?
    redis.get(category_key)
  end

  private

  # 取得每类商品应该的结算价格
  def collect_categories_price
    collect_categories_sell_count
    categories_sell_count.each do |category_key, sell_count|
      purchase_price = fee[category_key][mapping_price_key(fee[category_key].keys, sell_count)]
      redis.set(category_key, purchase_price, ex: EXPIRE_SECONDS)
    end
  end

  # 取得每类商品销售的数量
  def collect_categories_sell_count
    orders.includes(order_items: [itemable: :product]).find_each do |order|
      order.order_items.each do |order_item|
        fee_key = mapping_category_key(order_item.itemable)
        categories_sell_count[fee_key] += order_item.quantity
      end
    end
  end

  def mapping_category_key(work)
    product_key = work.product.key
    category_key = work.product.category.key
    return rule[category_key] unless rule[category_key].is_a? Hash
    rule[category_key][product_key]
  end

  # @input:
  #   keys [0, 101, 501, 1000]
  #   sell_count: 200
  # @return 101
  def mapping_price_key(keys, sell_count)
    keys.reverse.find { |a| a <= sell_count }
  end
end
