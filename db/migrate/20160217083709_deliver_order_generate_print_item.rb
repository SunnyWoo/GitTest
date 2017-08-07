class DeliverOrderGeneratePrintItem < ActiveRecord::Migration
  def change
    Order.paid.where(approved: true).delivery.find_each do |order|
      order.need_deliver_order_items.each(&:clone_to_print_items)

      order.need_deliver_order_items.each do |order_item|
        order_item.deliver! if order_item.may_deliver?
        if order_item.sublimated?
          order_item.update(aasm_state: 'received')
          order_item.print_items.update_all(aasm_state: 'received')
        end
      end
    end
  end
end
