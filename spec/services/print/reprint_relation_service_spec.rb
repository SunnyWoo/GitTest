require 'spec_helper'

describe Print::ReprintRelationService do
  context '#execute' do
    context 'when print_type is customer_service_retprint' do
      Given!(:package) { create :package }
      Given!(:print) { create :print_item, aasm_state: 'pending', package_id: package.id }
      Given!(:print1) { create :print_item, :with_onboard, package_id: package.id }
      Given!(:print2) { create :print_item, :with_onboard, package_id: package.id }
      Given(:service) { Print::ReprintRelationService.new(print.id, 'customer_service_retprint') }
      before { package.toboard }

      When { service.execute }
      Then { print.reload.package_id.nil? }
      And { print1.reload.package_id == package.id }
      And { print2.reload.package_id == package.id }
    end

    context 'when print_type is warehouse_retprint' do
      Given!(:package) { create :package }
      Given!(:package_id) { package.id }
      Given(:order_item) { create :order_item }
      Given!(:print) { create :print_item, aasm_state: 'pending', package_id: package.id }
      Given!(:print1) { create :print_item, :with_onboard, package_id: package.id }
      Given!(:print2) { create :print_item, :with_onboard, package_id: package.id }
      Given!(:print4) { create :print_item, :with_onboard, package_id: package.id, order_item: order_item }
      Given!(:print5) { create :print_item, :with_onboard, package_id: package.id, order_item: order_item }
      Given(:service) { Print::ReprintRelationService.new(print.id, 'warehouse_retprint') }
      before do
        print2.order_item.update(delivered: true)
      end

      When { service.execute }
      Then { print.reload.package_id.nil? }
      And { print1.reload.package_id.nil? }
      And { print2.reload.package_id.nil? }
      And { Package.exists?(package_id) == false }
      And { print.reload.pending? }
      And { print1.reload.qualified? }
      And { print2.reload.received? }
      And { print1.order_item.qualified? }
      And { print2.order_item.reload.received? }
    end
  end
end
