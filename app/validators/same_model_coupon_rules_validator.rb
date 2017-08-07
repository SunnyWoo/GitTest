class SameModelCouponRulesValidator < ActiveModel::Validator
  # 不允許設置出现單一商品同時滿足兩個優惠條件
  # 以下情况不允许：
  #       1: 设计师 ＋ ProductModel
  #       2: 2个条件只有一个或者没有设置设计师，但是出现相同ProductModel
  #       3: 2个条件出现相同设计师并且有相同的ProductModel
  #       4: ProductCategory选择了all选项的话，另一个条件选择了［订单总额超过］之外的选项
  def validate(record)
    return if same_rules?(record) || record.coupon_rules.map(&:condition).include?('threshold')
    model_ids_arr, designer_ids_arr = designers_and_models_in_coupon_rules(record)
    has_same_designer = same_in_array(designer_ids_arr).present?
    has_same_model = same_in_array(model_ids_arr).present?
    if (designer_ids_arr.size == 1 && model_ids_arr.count == 1) ||
       ((designer_ids_arr.size < 2 || has_same_designer) && has_same_model)
      record.errors.add(:coupon_rules, :invalid_coupon_rules)
    end
  end

  def same_rules?(record)
    return true if record.coupon_rules.size < 2
    rules = record.coupon_rules.map do |coupon_rule|
      coupon_rule.attributes.delete_if { |key| key.in? %w(id quantity created_at updated_at) }
    end
    rules[0] == rules[1]
  end

  def same_in_array(array)
    array[0].to_a.map(&:to_i) & array[1].to_a.map(&:to_i)
  end

  def designers_and_models_in_coupon_rules(record)
    model_ids_arr = [[], []]
    designer_ids_arr = [[], []]
    record.coupon_rules.each_with_index do |rule, index|
      case rule.condition
      when 'include_works'
        model_ids_arr[index] << rule.work_gids.map { |gid| GlobalID::Locator.locate(gid).model_id }
      when 'include_designers'
        designer_ids_arr[index] << rule.designer_ids
      when 'include_product_models'
        model_ids_arr[index] << rule.product_model_ids
      when 'include_designers_models'
        designer_ids_arr[index] << rule.designer_ids
        model_ids_arr[index] << rule.product_model_ids
      when 'include_product_categories'
        model_ids_arr[index] << if rule.product_category_ids.map(&:to_i).include?(-1)
                                  ProductModel.available.map(&:id)
                                else
                                  ProductModel.available.where(category_id: rule.product_category_ids).map(&:id)
                                end
      end
    end
    [model_ids_arr.reject(&:blank?).each(&:flatten!), designer_ids_arr.reject(&:blank?).each(&:flatten!)]
  end
end
