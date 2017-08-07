class Admin::PromotionPresenter
  attr_reader :promotion

  def initialize(promotion)
    @promotion = Admin::PromotionDecorator.new(promotion)
  end

  def promotables
    return [] unless promotion.item_level?
    @promotables ||= begin
      @promotion.references.includes(:promotable, :price_tier).map do |ref|
        Promotable.new(ref.promotable, @promotion, ref.price_tier)
      end
    end
  end

  class Promotable
    PRICE_METHODS = {
      ProductCategory => ->(_r) { '' },
      ProductModel => ->(r) { Price.new(r.customized_special_prices) },
      StandardizedWork => ->(r){ Price.new(r.prices) }
    }.freeze

    CATEGORY_METHODS = {
      ProductCategory => ->(r) { r.name },
      ProductModel => ->(r) { r.category.name },
      StandardizedWork => ->(r){ r.product.category.name }
    }.freeze

    def initialize(record, promotion, price_tier = nil)
      @record = record
      @promotion = promotion
      @price_tier = price_tier && Price.new(price_tier.prices)
    end

    def name
      @record.name
    end

    def scope_name
      I18n.t(@record.class.name.underscore, scope: 'promotions.promotable_scope')
    end

    def category_name
      case @record
      when StandardizedWork
        @record.product.category.name
      when ProductModel
        @record.category.name
      when ProductCategory
        @record.name
      end
    end

    def price
      PRICE_METHODS[@record.class].call(@record).presence
    end

    def selling_price
      if @promotion.unified_discount?
        formula = @promotion.discount_formula
        formula.calculate(price) || @promotion.h.render_discount_formula(formula)
      else
        @price_tier || price
      end
    end
  end
end
