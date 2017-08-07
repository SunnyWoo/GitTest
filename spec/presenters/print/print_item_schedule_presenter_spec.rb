require 'spec_helper'

describe Print::PrintItemSchedulePresenter do
  context '#initialize' do
    context 'default type is urgent' do
      Given(:schedule_presenter) { Print::PrintItemSchedulePresenter.new }
      Then { schedule_presenter.type == 'urgent' }
    end
  end

  context '#print_items' do
    context 'when aasm_state is qualified, onboard and shipping' do
      Given!(:print_item1) { create :print_item, aasm_state: :qualified }
      Given!(:print_item2) { create :print_item, aasm_state: :onboard }
      Given!(:print_item3) { create :print_item, aasm_state: :shipping }
      Given(:schedule_presenter) { Print::PrintItemSchedulePresenter.new(type: 'normal') }
      Then { schedule_presenter.print_items.include?(print_item1) == false }
      And { schedule_presenter.print_items.include?(print_item2) == false }
      And { schedule_presenter.print_items.include?(print_item3) == false }
    end

    context 'when state is pending, uploading, printed, delivering, received and sublimated' do
      Given!(:print_item1) { create :print_item, aasm_state: :pending }
      Given!(:print_item2) { create :print_item, aasm_state: :uploading }
      Given!(:print_item3) { create :print_item, aasm_state: :printed }
      Given!(:print_item4) { create :print_item, aasm_state: :delivering }
      Given!(:print_item5) { create :print_item, aasm_state: :received }
      Given!(:print_item6) { create :print_item, aasm_state: :sublimated }
      Given(:schedule_presenter) { Print::PrintItemSchedulePresenter.new(type: 'normal') }
      Then { schedule_presenter.print_items.include?(print_item1) }
      And { schedule_presenter.print_items.include?(print_item2) }
      And { schedule_presenter.print_items.include?(print_item3) }
      And { schedule_presenter.print_items.include?(print_item4) }
      And { schedule_presenter.print_items.include?(print_item5) }
      And { schedule_presenter.print_items.include?(print_item6) }
    end

    context 'when enable_schedule is false' do
      Given!(:print_item) { create :print_item, aasm_state: :pending, enable_schedule: false }
      Given(:schedule_presenter) { Print::PrintItemSchedulePresenter.new(type: 'normal') }
      Then { schedule_presenter.print_items.include?(print_item) == false }
    end

    context 'when search by number' do
      Given!(:print_item1) { create :print_item, aasm_state: :printed, timestamp_no: '112233' }
      Given!(:print_item2) { create :print_item, aasm_state: :delivering, timestamp_no: '445566' }
      Given(:schedule_presenter) { Print::PrintItemSchedulePresenter.new(type: 'normal', number: '112233') }
      Then { schedule_presenter.print_items.include?(print_item1) }
      And { schedule_presenter.print_items.include?(print_item2) == false }
    end
  end
end
