module CombinedShipping
  def mark_merge_target_ids
    merge_targets.update_all(merge_target_ids: merge_targets.pluck(:id))
    merge_targets.each { |order| order.update flags: order.flags << :combined_shipping }
    self.need_mark_merge_target_ids = false
    save
  end

  def can_merge_order?
    shipping_fee == shipping_fee_discount &&
      need_mark_merge_target_ids &&
      paid? &&
      merge_target_ids.blank? &&
      merge_targets.size > 1
  end

  # 拼单条件
  # 1. 地址相同
  # 2. 必须是免运情况(判定方式为shipping_fee==shipping_fee_discount)
  def merge_targets
    @merge_targets ||= Order.paid.joins(:shipping_info).
                       where("billing_profiles.name" => shipping_info.name, "billing_profiles.phone" => shipping_info.phone).
                       where("billing_profiles.address_data->>'address' = ? OR billing_profiles.address = ?", shipping_info.address, shipping_info.address).
                       where('orders.shipping_fee = orders.shipping_fee_discount')
  end

  def delete_merge_target_ids
    if merge_target_ids.size <= 2
      Order.where(id: merge_target_ids).update_all(merge_target_ids: [])
    else
      Order.where(id: (merge_target_ids - [id])).find_each do |order|
        merge_target_ids = order.merge_target_ids.dup
        merge_target_ids.delete(id)
        order.update_column(:merge_target_ids, merge_target_ids)
      end
      update_column(:merge_target_ids, [])
    end
  end
end
