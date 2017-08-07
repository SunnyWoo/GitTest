require 'spec_helper'

describe OrderDecorator do
  Given(:order) { create :order }
  Given(:order_item) { create :order_item, order: order }
  Given!(:print_item_received) { create :print_item, order_item: order_item, aasm_state: 'received' }
  Given!(:print_item_onboard) { create :print_item, order_item: order_item, aasm_state: 'onboard' }
  Given!(:print_item_qualified) { create :print_item, order_item: order_item, aasm_state: 'qualified' }
  Given!(:print_item_pending) { create :print_item, order_item: order_item, aasm_state: 'pending' }
  Given(:order_decorate) { order.reload.decorate }

  context '#print_items_completed_count' do
    Then { order_decorate.print_items_completed_count == 3 }
  end

  context '#order_items_count' do
    Then { order_decorate.order_items_count == 2 }
  end

  context '#print_items_count' do
    Then { order_decorate.print_items_count == 4 }
  end

  context '#allow_package??' do
    context 'return false' do
      before do
        allow(order_decorate).to receive(:print_items_count).and_return(1)
        allow(order_decorate).to receive(:print_items_completed_count).and_return(2)
      end
      Then { order_decorate.allow_package? == false }
    end

    context 'return true' do
      before do
        allow(order_decorate).to receive(:print_items_count).and_return(3)
        allow(order_decorate).to receive(:print_items_completed_count).and_return(3)
      end
      Then { order_decorate.allow_package? == true }
    end
  end

  context '#forbid_package?' do
    context 'return true' do
      before { allow(order_decorate).to receive(:allow_package).and_return(false) }
      Then { order_decorate.forbid_package? == true }
    end
  end

  context '#package_button_state' do
    context 'when forbid package' do
      before { allow(order_decorate).to receive(:forbid_package?).and_return(true) }
      Then { order_decorate.package_button_state == 'disabled' }
    end

    context 'when not forbid package' do
      before { allow(order_decorate).to receive(:forbid_package?).and_return(false) }
      Then { order_decorate.package_button_state == '' }
    end
  end

  context '#progress_rate' do
    Then { order_decorate.progress_rate == 75 }
  end

  context '#prepare_to_merge?' do
    context 'return true' do
      before do
        allow(order_decorate).to receive(:can_be_packaged_all?).and_return(true)
        allow(order_decorate).to receive(:merge_target_ids).and_return([1, 2])
      end
      Then { order_decorate.prepare_to_merge? }
    end

    context 'return false' do
      Then { order_decorate.prepare_to_merge? == false }
    end
  end
end
