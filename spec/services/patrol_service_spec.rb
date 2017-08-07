require 'spec_helper'

describe PatrolService do
  Given(:service) { PatrolService.new }

  context '#print_item_quantity_check' do
    Given(:templates) {
      {
        fixed: '發現到訂單 %s 中，OrderItem#%s 沒有 PrintItem，已補印',
        need_fix: '發現到訂單 %s 中，OrderItem#%s 有缺少 PrintItem, 請上 console 確認並處理',
        need_delete: '發現到訂單 %s 中，OrderItem#%s PrintItem 過多，請上 console 確認並處理',
        need_delete_fixed: '發現到訂單 %s 中，OrderItem#%s PrintItem 過多，已重新複製 PrintItem',
      }
    }
    Given!(:order) { create(:paid_order, approved: true) }
    When { order.reload.order_items.first.update_columns(quantity: 2) }
    Given(:order_item) { order.reload.order_items.first }
    before { allow(SlackNotifier).to receive(:send) }

    context 'fixed report' do
      Given(:msg) { order.order_items.map { |oi| sprintf(templates[:fixed], oi.order.order_no, oi.id) }.join("\n") }
      When { service.print_item_quantity_check }
      Then { expect(SlackNotifier).to have_received(:send).with(msg) }
    end

    context 'need_fix report' do
      Given!(:print_item) { create(:print_item, order_item: order_item) }
      Given(:msg) { order.order_items.map { |oi| sprintf(templates[:need_fix], oi.order.order_no, oi.id) }.join("\n") }
      When { service.print_item_quantity_check }
      Then { expect(SlackNotifier).to have_received(:send).with(msg) }
    end

    context 'need_delete' do
      before do
        order_item.print!
        4.times { create(:print_item, order_item: order_item) }
      end
      Given(:msg) { order.order_items.map { |oi| sprintf(templates[:need_delete], oi.order.order_no, oi.id) }.join("\n") }
      When { service.print_item_quantity_check }
      Then { expect(SlackNotifier).to have_received(:send).with(msg) }
    end

    context 'need_delete_fixed' do
      before { 4.times { create(:print_item, order_item: order_item) } }
      Given(:msg) { order.order_items.map { |oi| sprintf(templates[:need_delete_fixed], oi.order.order_no, oi.id) }.join("\n") }
      When { service.print_item_quantity_check }
      Then { expect(SlackNotifier).to have_received(:send).with(msg) }
    end

    context 'everything is fine' do
      before { 2.times { create(:print_item, order_item: order_item) } }
      When { service.print_item_quantity_check }
      Then { expect(SlackNotifier).not_to have_received(:send) }
    end
  end
end
