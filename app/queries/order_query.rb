class OrderQuery
  def initialize(relation = Order)
    @relation = relation
    @conds = {}
  end

  def by_categories(*categories)
    category_ids = normalize_to_ids(categories)
    product_ids = ProductModel.where(category_id: category_ids).pluck(:id)
    by_products(*product_ids)
  end

  def by_products(*products_or_ids)
    product_ids = normalize_to_ids(products_or_ids)

    itemable_klass_to_ids = [
      Work, ArchivedWork,
      StandardizedWork, ArchivedStandardizedWork
    ].each_with_object({}) do |klass, h|
      h[klass] = klass.where(model_id: product_ids).pluck(:id)
    end

    add_condition_by_itemable_id_mappings(itemable_klass_to_ids)
    self
  end

  def by_standardized_works(*standardized_works_or_ids)
    standardized_work_ids = normalize_to_ids(standardized_works_or_ids)
    itemable_klass_to_ids = {
      StandardizedWork => standardized_work_ids,
      ArchivedStandardizedWork => ArchivedStandardizedWork.where(original_work_id: standardized_work_ids).pluck(:id)
    }

    add_condition_by_itemable_id_mappings(itemable_klass_to_ids)

    self
  end

  def execute
    @relation.where(@conds)
  end

  private

  # { itemable_type_klass => itemable_ids }
  def add_condition_by_itemable_id_mappings(mappings)
    order_ids = mappings.map do |klass, itemable_ids|
      OrderItem.where(itemable_type: klass.to_s, itemable_id: itemable_ids).pluck(:order_id)
    end.flatten.uniq

    @conds[:id] = @conds[:id] ? (@conds[:id] & order_ids) : order_ids
  end

  def normalize_to_ids(object_or_ids)
    objects = Array(object_or_ids).flatten
    case Array(objects)[0]
    when Integer
      objects
    when ActiveRecord::Base
      objects.map(&:id)
    end
  end
end
