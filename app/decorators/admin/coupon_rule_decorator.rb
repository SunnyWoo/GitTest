class Admin::CouponRuleDecorator < ApplicationDecorator
  delegate_all

  def info
    case object.condition
    when 'threshold'
      threshold_info
    when 'include_designers'
      designers_info
    when 'include_product_models'
      products_info
    when 'include_works'
      works_info
    when 'include_designers_models'
      designers_models_info
    when 'include_product_categories'
      categories_info
    when 'include_bdevent'
      bdevent_info
    end
  end

  def threshold_info
    [I18n.t('js.coupon.new.order_over'),
     threshold_prices_in_currency].join(':')
  end

  def designers_info
    [I18n.t('js.coupon.new.specify_designers') + quantity_info,
     designers_name].join(':')
  end

  def products_info
    [I18n.t('js.coupon.new.specify_products') + quantity_info,
     products_name].join(':')
  end

  def designers_models_info
    [I18n.t('js.coupon.new.specify_products_designers') + quantity_info,
     designers_name + products_name].join(':')
  end

  def categories_info
    [I18n.t('js.coupon.new.specify_product_categories') + quantity_info,
     categories_name].join(':')
  end

  def works_info
    [I18n.t('js.coupon.new.specify_work') + quantity_info,
     works_name].join(':')
  end

  def bdevent_info
    [I18n.t('js.coupon.new.specify_bdevent'),
     Bdevent.find_by(id: object.bdevent_id).try(:title)].join(':')
  end

  def quantity_info
    "(#{I18n.t('js.coupon.new.rule_quantity')}:#{object.quantity})"
  end

  private

  def designers_name
    Designer.where(id: object.designer_ids).pluck(:username).join(' | ')
  end

  def products_name
    ProductModel.where(id: object.product_model_ids).pluck(:name).join(' | ')
  end

  def categories_name
    return 'All' if object.product_category_ids.map(&:to_i).include?(-1)
    ProductCategory.where(id: object.product_category_ids).map(&:name).join(' | ')
  end

  def works_name
    object.work_gids.map { |gid| GlobalID::Locator.locate(gid) }.map(&:name).join(' | ')
  end

  def threshold_prices_in_currency(currency = Region.default_currency)
    [object.threshold_prices[currency], currency].join(' ')
  end
end
