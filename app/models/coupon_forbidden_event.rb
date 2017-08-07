# 設定coupon id
# 某個 category_keys or product_keys 不能使用
# begins_at 開始時間
# ends_at 結束時間
# region 設定排除的 region (china or global or [])
# category_keys 設定排除的 category_keys
# product_keys 設定排除的 product_keys
# coupon_ids 設定排除的 coupon_ids *一定要設定

class CouponForbiddenEvent
  include Virtus.model

  attribute :begins_at, DateTime
  attribute :ends_at, DateTime
  attribute :region, Array[String]
  attribute :category_keys, Array[String]
  attribute :product_keys, Array[String]
  attribute :coupon_ids, Array[Integer]

  SOURCE_FILE = Rails.root.join('config', 'coupon_forbidden_event.yml').to_s.freeze

  class << self
    include Enumerable

    delegate :each, :size, to: :all

    def active
      select(&:active?)
    end

    def all
      @all ||= source.map { |data| new(data) }
    end

    def source
      Array(YAML.load_file(SOURCE_FILE)[Rails.env.to_s].try(:[], 'events'))
    end
  end

  def active?
    # (begins_at.to_i..ends_at.to_i).include?(Time.zone.now.to_i)
    (begins_at..ends_at).cover?(Time.zone.now)
  end

  # coupon 需要帶入 root coupon
  def blocking?(coupon, order, _user)
    blocked_on_region? && blocked_on_coupon?(coupon) && blocked_on_product_line?(order)
  end

  def blocked_on_coupon?(coupon)
    coupon_ids.include?(coupon.id)
  end

  def blocked_on_product_line?(order)
    return true if (Array(category_keys) & extract_category_keys(order)).any?
    return true if (Array(product_keys) & extract_product_keys(order)).any?
    false
  end

  def blocked_on_region?
    (Array(Region.region) & region).any?
  end

  private

  def extract_category_keys(order)
    order.order_items.map do |x|
      x.itemable.product.category.key rescue nil
    end.compact.uniq
  end

  def extract_product_keys(order)
    order.order_items.map do |x|
      x.itemable.product.key rescue nil
    end.compact.uniq
  end
end
