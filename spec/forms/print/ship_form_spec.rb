require 'spec_helper'

describe Print::ShipForm do
  context '#ship!' do
    context 'when split order' do
      Given(:express) {  create :express }
      Given(:package) {  create :package, aasm_state: :onboard }
      Given(:order) { create :order }
      Given(:order_item) { create :order_item, order: order }
      Given(:params) do
        {
          package_id: package.id,
          invoice_number: '',
          ship_code: 'ship code'
        }
      end
      before do
        order.reload.order_items.each(&:clone_to_print_items)
        order.update_attribute(:aasm_state, :paid)
        order.order_items.update_all(aasm_state: :onboard)
        order.print_items.update_all(aasm_state: :onboard)
        order.reload.print_items.last.update(package_id: package.id)
      end
      Given(:form) { Print::ShipForm.new(params) }
      When { form.ship! }
      Then { package.reload.shipping? }
      And { order.reload.ship_code == 'ship code' }
    end

    context 'when splice order' do
      Given(:express) {  create :express }
      Given(:package) {  create :package, aasm_state: :onboard }
      Given(:order1) { create :order }
      Given(:order2) { create :order }
      Given(:params) do
        {
          package_id: package.id,
          invoice_number: '',
          ship_code: 'ship code'
        }
      end
      before do
        order1.reload.order_items.each(&:clone_to_print_items)
        order2.reload.order_items.each(&:clone_to_print_items)
        order1.update_attribute(:aasm_state, :paid)
        order2.update_attribute(:aasm_state, :paid)
        order1.order_items.update_all(aasm_state: :onboard)
        order2.order_items.update_all(aasm_state: :onboard)
        order1.reload.print_items.update_all(aasm_state: :onboard, package_id: package.id)
        order2.reload.print_items.update_all(aasm_state: :onboard, package_id: package.id)
      end
      Given(:form) { Print::ShipForm.new(params) }
      When { form.ship! }
      Then { package.reload.shipping? }
      And { package.ship_code == 'ship code' }
      And { order1.reload.ship_code == 'ship code' }
      And { order2.reload.ship_code == 'ship code' }
    end
  end
end
