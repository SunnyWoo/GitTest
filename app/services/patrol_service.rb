class PatrolService
  def make_sure_deliverd_orders_have_coupon
    coupon = Coupon.root.find_by code: Settings.deliver_order.coupon_code
    order_nos = Order.where(coupon_id: nil, aasm_state: 'paid').where.not(remote_id: nil).map do |order|
      order.coupon = coupon
      order.save
      order.calculate_price!
      order.order_no
    end
    SlackNotifier.send_msg("將拋單訂單 #{order_nos.join(' ')} 補上 coupon code") unless order_nos.empty?
  end

  def print_item_quantity_check
    templates = {
      fixed: '發現到訂單 %s 中，OrderItem#%s 沒有 PrintItem，已補印',
      need_fix: '發現到訂單 %s 中，OrderItem#%s 有缺少 PrintItem, 請上 console 確認並處理',
      need_delete: '發現到訂單 %s 中，OrderItem#%s PrintItem 過多，請上 console 確認並處理',
      need_delete_fixed: '發現到訂單 %s 中，OrderItem#%s PrintItem 過多，已重新複製 PrintItem',
    }
    msgs = []
    weird_order_items.each do |oi|
      if oi.print_items.empty? # 補印
        oi.send(:clone_to_print_items)
        key = :fixed
      elsif oi.print_items.size < oi.quantity # 缺少 PrintItem 但不是全沒有，通常是補上沒有的部分
        key = :need_fix
      elsif (oi.print_items.size > oi.quantity) && oi.pending? # PrintItme 過多 重跑 clone_to_print_items 且 OrderItem state is pending
        oi.send(:clone_to_print_items)
        key = :need_delete_fixed
      else # 有過多的 PrintItem，
        key = :need_delete
      end
      msgs << sprintf(templates[key], oi.order.order_no, oi.id)
    end
    SlackNotifier.send_msg(msgs.join("\n")) if msgs.count > 0
  end

  protected

  # 與 #print_item_quantity_check 連動
  def weird_order_items
    order_ids = Order.paid.approved.select(:id)
    OrderItem.includes(:print_items).where(order_id: order_ids)
             .select { |oi| oi.print_items.size != oi.quantity }
  end
end
