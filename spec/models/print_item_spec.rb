# == Schema Information
#
# Table name: print_items
#
#  id              :integer          not null, primary key
#  order_item_id   :integer
#  timestamp_no    :integer
#  aasm_state      :string(255)
#  print_at        :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  model_id        :integer
#  prepare_at      :datetime
#  sublimated_at   :datetime
#  onboard_at      :datetime
#  package_id      :integer
#  qualified_at    :datetime
#  shipped_at      :datetime
#  enable_schedule :boolean          default(TRUE)
#

require 'spec_helper'

RSpec.describe PrintItem, type: :model do
  it 'FactoryGirl' do
    expect(build(:print_item)).to be_valid
  end

  it { should belong_to(:package) }
  it { should validate_presence_of(:product) }

  it 'sets to printed when all print items were printed' do
    order_item = create(:order_item, quantity: 5, order: create(:order))
    order_item.clone_to_print_items
    expect(order_item.print_items.size).to eq(5)
    order_item.print_items[0...4].each do |print_item|
      expect(print_item).to be_pending
      print_item.upload!
      print_item.print!
      expect(order_item).not_to be_printed
    end
    print_item = order_item.print_items.last
    expect(print_item).to be_pending
    print_item.upload!
    print_item.print!
    expect(order_item).to be_printed
  end

  describe '#reprint' do
    before do
      @order_item = create(:order_item, quantity: 5, order: create(:order))
      @order_item.clone_to_print_items
      @print_items = @order_item.print_items
      @print_items.each(&:upload!)
      @print_items.each(&:print!)
    end

    context 'check order order_item state' do
      it 'return true' do
        print_item = @print_items.first
        expect(print_item.aasm_state).to eq('printed')
        expect(@order_item.aasm_state).to eq('printed')
        @order_item.order.update_attributes(packaging_state: :all_packaged, shipping_state: :all_shipping)
        expect(@order_item.order.work_state).to eq('working')
        print_item.reload
        print_item.reprint!

        expect(print_item.aasm_state).to eq('pending')
        expect(@order_item.reload.aasm_state).to eq('pending')
        expect(@order_item.order.work_state).to eq('ongoing')
        expect(@order_item.order.packaging_state).to eq('package_ongoing')
        expect(@order_item.order.shipping_state).to eq('shipping_ongoing')
      end

      it 'rails Error when order_item need deliver' do
        print_item = @print_items.first
        expect(print_item.aasm_state).to eq('printed')
        expect(@order_item.aasm_state).to eq('printed')
        expect(@order_item.order.work_state).to eq('working')
        allow(print_item).to receive(:need_deliver?).and_return(true)
        print_item.reload
        expect { print_item.reprint! }.to raise_error(AASM::InvalidTransition)
      end

      it 'reprint will change prepare_at when print_type is customer_service_retprint' do
        print_item = @print_items.first
        print_item.reload
        time = Time.zone.now - 1.day
        print_item.update_column(:prepare_at, time)
        print_item.reprint!(print_type: 'customer_service_retprint', reason: 'reason')

        expect(print_item.prepare_at).not_to eq(time)
      end

      it 'reprint will not change prepare_at when print_type is warehouse_retprint' do
        print_item = @print_items.first
        print_item.reload
        time = Time.zone.now - 1.day
        print_item.update_column(:prepare_at, time)
        print_item.reprint!(print_type: 'warehouse_retprint', reason: 'reason')

        expect(print_item.prepare_at).to eq(time)
      end

      it 'reprint will not change prepare_at when print_type is nil' do
        print_item = @print_items.first
        print_item.reload
        time = Time.zone.now - 1.day
        print_item.update_column(:prepare_at, time)
        print_item.reprint!

        expect(print_item.prepare_at).to eq(time)
      end

      it 'delete temp shelf' do
        print_item = @print_items.first
        print_item.reload
        print_item.update_attribute(:aasm_state, :sublimated)
        print_item.create_temp_shelf(serial: '123')
        print_item.reprint!
        expect(print_item.reload.temp_shelf).to eq(nil)
      end
    end
  end

  describe '#output_files' do
    context 'itemable is a ArchivedStandardizedWork' do
      Given(:print_item) { create(:print_item, :with_archived_standardized_work_item) }
      Then { print_item.output_files == print_item.order_item.itemable.output_files }
    end
    context 'itemable is a other kinds of work' do
      Given(:print_item) { create(:print_item) }
      Then { print_item.output_files == [] }
    end
  end

  describe '#not_sublimated?' do
    context 'pending print item' do
      Given(:print_item) { create(:print_item) }
      Then { print_item.not_sublimated? }
    end

    context 'sublimated print item' do
      Given(:print_item) { create(:print_item) }
      When do
        print_item.upload
        print_item.print
        print_item.sublimate
      end
      Then { print_item.not_sublimated? == false }
    end
  end

  describe 'aasm' do
    context '#deliver' do
      context 'when product remote?' do
        Given(:product) { create :product_model, remote_key: 'key' }
        Given(:print_item) { build :print_item, product: product }
        When { print_item.deliver! }
        Then { print_item.aasm_state == 'delivering' }
      end

      context 'when product not remote?' do
        Given(:print_item) { create :print_item }
        Then { print_item.aasm_state == 'pending' }
        And { expect { print_item.deliver! }.to raise_error(AASM::InvalidTransition) }
      end
    end
  end

  context '#reprint' do
    context 'when reprint by factory_retprint' do
      Given!(:package) { create :package }
      Given!(:print1) { create :print_item, :with_onboard, package_id: package.id }
      Given!(:print2) { create :print_item, :with_onboard, package_id: package.id }
      Given(:reprint_params) { { print_type: 'factory_retprint', reason: 'reason' } }
      When { print1.reprint!(reprint_params) }
      Then { print1.reload.package_id.nil? }
      And { print2.reload.package_id.nil? }
    end

    context 'when reprint by customer_service_retprint' do
      Given!(:package) { create :package }
      Given!(:print1) { create :print_item, :with_onboard, package_id: package.id }
      Given!(:print2) { create :print_item, :with_onboard, package_id: package.id }
      Given(:reprint_params) { { print_type: 'customer_service_retprint', reason: 'reason' } }
      When { print1.reprint!(reprint_params) }
      Then { print1.reload.package_id.nil? }
      And { print2.reload.package_id == package.id }
    end
  end

  context '#check' do
    context 'transitions form sublimated to qualified' do
      Given(:order_item) { create :order_item, aasm_state: 'sublimated' }
      Given!(:print_item) { build :print_item, order_item: order_item, aasm_state: 'sublimated' }
      When { print_item.check! }
      Then { print_item.reload.qualified? }
      And { order_item.reload.qualified? }
    end
  end

  context '#toboard' do
    context 'transitions form received to onboard' do
      Given(:order_item) { create :order_item, aasm_state: 'qualified' }
      Given!(:print_item) { create :print_item, order_item: order_item, aasm_state: 'qualified' }
      When { print_item.toboard! }
      Then { print_item.reload.onboard? }
      And { order_item.reload.onboard? }
    end

    context 'transitions form qualified to onboard' do
      Given(:order_item) { create :order_item, aasm_state: 'qualified' }
      Given!(:print_item) { create :print_item, order_item: order_item, aasm_state: 'qualified' }
      Given!(:print_item2) { create :print_item, order_item: order_item, aasm_state: 'qualified' }
      When { print_item.toboard! }
      Then { print_item.reload.onboard? }
      And { order_item.reload.qualified? }
    end
  end

  context '#ship' do
    context 'order_item#print_items all shipping' do
      Given(:order_item) { create :order_item, aasm_state: 'onboard' }
      Given!(:print_item) { create :print_item, order_item: order_item, aasm_state: 'onboard' }
      When { print_item.ship! }
      Then { print_item.reload.shipping? }
      And { order_item.reload.shipping? }
    end

    context 'order_item#print_items not all shipping' do
      Given(:order_item) { create :order_item, aasm_state: 'onboard' }
      Given!(:print_item) { create :print_item, order_item: order_item, aasm_state: 'onboard' }
      Given!(:print_item2) { create :print_item, order_item: order_item, aasm_state: 'onboard' }
      When { print_item.ship! }
      Then { print_item.reload.shipping? }
      And { order_item.reload.onboard? }
    end
  end

  context '#external_production' do
    context 'transitions form uploading to delivering' do
      Given(:order_item) { create :order_item, aasm_state: 'pending' }
      Given!(:print_item) { build :print_item, order_item: order_item, aasm_state: 'uploading' }
      When { print_item.external_production! }
      Then { print_item.reload.delivering? }
      And { order_item.reload.delivering? }
    end
  end
end
