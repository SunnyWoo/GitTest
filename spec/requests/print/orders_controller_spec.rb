require 'spec_helper'

RSpec.describe Print::OrdersController, type: :request do
  before do
    role = Role.create(name: 'Order')
    role.permissions.create(resource: 'Order', action: 'package')
    role.permissions.create(resource: 'Order', action: 'disable_schedule')
    role_group = FactoryRoleGroup.create(name: 'Admin')
    role_group.roles << role

    login_factory_member

    member = FactoryMember.last
    member.role_groups = [FactoryRoleGroup.last]
  end

  describe '#package' do
    context 'normal package fail' do
      Given(:print_item) { create(:print_item) }
      When { put print_order_package_path(print_item.order_item.order) }
      Then { flash[:notice] == '訂單未完全熱轉印無法打包。' }
      And { print_item.reload.onboard? == false }
    end

    context 'normal package success' do
      Given(:print_item) { create(:print_item, :with_qualified) }
      Given(:order) { print_item.order_item.order }
      before {
        order.reload.order_items.where(aasm_state: 'pending').update_all(aasm_state: 'received')
      }
      When { put print_order_package_path(order) }
      Then { flash[:notice] == '訂單打包完成。' }
      And { print_item.reload.onboard? }
    end

    context 'has print_item reprint' do
      Given(:print_item) { create(:print_item, :with_qualified) }
      Given(:order) { print_item.order_item.order }
      before do
        Package.create_package_with_print_items(print_item_ids: order.print_items.pluck(:id))
        print_item.reload
        print_item.reprint!(print_type: 'customer_service_retprint', reason: 'reason')
        print_item.reload
        print_item.upload!
        print_item.print!
        print_item.sublimate!
        print_item.check!
      end
      When { put print_order_package_path(print_item.order_item.order) }
      Then { flash[:notice] == '訂單打包完成。' }
      And { print_item.reload.onboard? }
    end
  end

  context '#disable_schedule' do
    Given!(:order) { create :order, aasm_state: :paid, enable_schedule: true }
    When { patch disable_schedule_print_order_path(order) }
    Then { order.reload.enable_schedule == false }
  end
end
