require 'spec_helper'

RSpec.describe Print::PrintItemsController, type: :request do
  before do
    role = Role.create(name: 'Order')
    role.permissions.create(resource: 'PrintItem', action: 'reprint')
    role.permissions.create(resource: 'PrintItem', action: 'disable_schedule')
    role_group = FactoryRoleGroup.create(name: 'Admin')
    role_group.roles << role

    login_factory_member

    member = FactoryMember.last
    member.role_groups = [FactoryRoleGroup.last]
  end

  let!(:print_item) { create(:print_item, aasm_state: 'onboard') }
  let(:print_history_params) do
    { print_history: { print_type: 'factory_retprint', reason: '工厂重印' } }
  end

  context '#reprint' do
    it 'print_item aasm_state should pending' do
      patch print_print_item_reprint_path(print_item.id, print_history_params)
      expect(response.code.to_i).to eq(302)
      expect(print_item.reload.aasm_state).to eq('pending')
      expect(print_item.order.work_state).to eq('ongoing')
      expect(print_item.order_item.aasm_state).to eq('pending')
    end
  end

  context '#disable_schedule' do
    Given!(:print_item) { create :print_item, aasm_state: :pending, enable_schedule: true }
    When { patch disable_schedule_print_print_item_path(print_item) }
    Then { print_item.reload.enable_schedule == false }
  end
end
