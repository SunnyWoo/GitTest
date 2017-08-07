# == Schema Information
#
# Table name: packages
#
#  id                    :integer          not null, primary key
#  aasm_state            :string(255)
#  ship_code             :string(255)
#  shipped_at            :datetime
#  created_at            :datetime
#  updated_at            :datetime
#  package_no            :string(255)
#  logistics_supplier_id :integer
#

require 'rails_helper'

RSpec.describe Package, type: :model do
  it { should have_many(:print_items) }
  it { should have_many(:order_items).through(:print_items) }
  it { should have_many(:orders).through(:order_items) }

  it 'FactoryGirl' do
    expect( build(:package) ).to be_valid
  end

  context 'AASM' do
    context '#toboard' do
      Given(:package) { create :package }
      Given!(:print_item) { create :print_item, package_id: package.id, aasm_state: 'qualified' }
      Given(:order_item) { print_item.order_item }
      Given(:order) { order_item.order }
      before do
        order.update_attribute(:aasm_state, :paid)
        order_item.update!(aasm_state: 'qualified')
      end
      When { package.reload.toboard! }
      Then { order_item.reload.onboard? }
      And { print_item.reload.onboard? }
      And { order.reload.packaging_state == 'part_packaged' }
    end

    context '#ship' do
      Given!(:order) { create :order, aasm_state: :paid }
      Given!(:order_item) { create :order_item, order: order, aasm_state: :onboard }
      Given!(:package) { create :package, aasm_state: :onboard }
      Given!(:print_item) { create :print_item, order_item: order_item, package: package, aasm_state: :onboard }
      When { package.reload.ship! }
      Then { order_item.reload.shipping? }
      And { order.reload.paid? }
      And { package.activities.last.key == 'shipped' }
      And { order.shipping_state == 'part_shipping' }
    end
  end

  context '.create_package_with_print_items' do
    context 'when params is print_items' do
      Given(:print_item1) { create :print_item, :with_qualified }
      Given(:print_item2) { create :print_item, :with_qualified }
      Given(:options) do
        {
          print_items: {
            print_item1.id => {},
            print_item2.id => {}
          }
        }
      end
      When { Package.create_package_with_print_items(options) }
      Given(:package_id) { Package.last.id }
      Then { print_item1.reload.package_id == package_id }
      And { print_item2.reload.package_id == package_id }
    end

    context 'when params is orders' do
      Given(:order1) { create :order, aasm_state: :paid }
      Given(:order2) { create :order, aasm_state: :paid }
      Given(:options) do
        {
          orders: {
            order1.id => {},
            order2.id => {}
          }
        }
      end
      before do
        order1.reload.order_items.each(&:clone_to_print_items)
        order1.order_items.update_all(aasm_state: 'qualified')
        order1.print_items.update_all(aasm_state: 'qualified')
        order2.reload.order_items.each(&:clone_to_print_items)
        order2.order_items.update_all(aasm_state: 'qualified')
        order2.print_items.update_all(aasm_state: 'qualified')
      end

      When { Package.create_package_with_print_items(options) }
      Given(:package) { Package.last }
      Then { package.print_items.pluck(:id).sort == (order1.print_items.pluck(:id) + order2.print_items.pluck(:id)).sort }
      And { package.package_no.present? }
      And { package.shipping_info.present? }
    end
  end
end
