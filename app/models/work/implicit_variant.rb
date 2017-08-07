# 目前variant还没有开始使用， 因此在创建work的时候并不会显式的提供variant_id或相关信息
# 由于该阶段product_model只有一个variant
# 所以暂时通过以下这种方法将work跟variant关联
module Work::ImplicitVariant
  extend ActiveSupport::Concern

  included do
    before_save :associate_variant
  end

  def associate_variant
    self.variant = product.variants.first
  end

  # overwrite for new_record
  def variant
    if new_record?
      product.variants.first
    else
      super
    end
  end
end
