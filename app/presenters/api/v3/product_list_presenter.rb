class Api::V3::ProductListPresenter
  include Enumerable
  delegate :each, :size, to: :groups

  def initialize(options)
    @options = options
  end

  def etag
    @etag ||= begin
      flag = ProductModel.joins(:category).select('COUNT(*) total, MAX(product_models.updated_at) max_product_id, MAX(product_categories.updated_at) max_category_id').to_a.first
      flag2 = Promotion.available.select('COUNT(*) total, MAX(promotions.updated_at) max_promotion_id').to_a.first

      segs = [
        platform, scope, available,
        flag.total,
        flag.max_category_id.try(:utc).try(:to_s, :number),
        flag.max_product_id.try(:utc).try(:to_s, :number),
        flag2.total,
        flag2.max_promotion_id.try(:utc).try(:to_s, :number),
        I18n.locale
      ]
      "api/v3/products/#{segs.join('-')}"
    end
  end

  alias_method :cache_key, :etag

  def platform
    @options.fetch(:platform)
  end

  def scope
    @options.fetch(:scope)
  end

  def available
    @options.fetch(:available)
  end

  def groups
    @groups ||= Pricing::ProductDecorator.decorate_collection(products).group_by(&:category).to_a
  end

  private

  def products
    ProductModel.includes(:translations, category: :translations)
                           .store_on_platform(platform, scope)
                           .platform_order_with_category(platform)
                           .send(available)
  end
end
