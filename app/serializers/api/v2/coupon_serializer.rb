# NOTE: only used in v2 api, remove me later
class Api::V2::CouponSerializer < ActiveModel::Serializer
  attributes :title, :code, :discount_type, :prices, :percentage, :condition,
             :threshold, :product_model_ids, :apply_target,
             :begin_at, :expired_at

  def prices
    object.send(:to_prices_hash)
  end

  def threshold
    object.threshold.prices
  end

  def include_prices?
    object.discount_type == 'fixed'
  end

  def include_percentage?
    object.discount_type == 'percentage'
  end

  def include_threshold?
    object.condition == 'threshold'
  end

  def include_product_model_ids?
    object.condition == 'include_product_models'
  end

  def include_apply_target?
    include_product_model_ids?
  end
end
