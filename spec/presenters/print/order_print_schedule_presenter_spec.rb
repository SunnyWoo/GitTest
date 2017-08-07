require 'spec_helper'

describe Print::OrderPrintSchedulePresenter do
  Given(:approved_at) { Time.zone.now - 1.day }
  context '#initialize' do
    context 'default type is urgent' do
      Given(:schedule_presenter) { Print::OrderPrintSchedulePresenter.new }
      Then { schedule_presenter.type == 'urgent' }
    end
  end

  context '#orders' do
    context 'when aasm_state is shipping, canceled, refunding and refunded' do
      Given!(:order1) { create :order, aasm_state: :shipping, approved_at: approved_at }
      Given!(:order2) { create :order, aasm_state: :canceled, approved_at: approved_at }
      Given!(:order3) { create :order, aasm_state: :refunding, approved_at: approved_at }
      Given!(:order4) { create :order, aasm_state: :refunded, approved_at: approved_at }
      Given(:schedule_presenter) { Print::OrderPrintSchedulePresenter.new(type: 'normal') }
      Then { schedule_presenter.orders.include?(order1) == false }
      And { schedule_presenter.orders.include?(order2) == false }
      And { schedule_presenter.orders.include?(order3) == false }
      And { schedule_presenter.orders.include?(order4) == false }
    end

    context 'when state is paid, packaged, part_refunded, part_refunding' do
      Given!(:order1) { create :order, aasm_state: :paid, approved_at: approved_at }
      Given!(:order2) { create :order, aasm_state: :packaged, approved_at: approved_at }
      Given!(:order3) { create :order, aasm_state: :part_refunded, approved_at: approved_at }
      Given!(:order4) { create :order, aasm_state: :part_refunding, approved_at: approved_at }
      Given(:schedule_presenter) { Print::OrderPrintSchedulePresenter.new(type: 'normal') }
      Then { schedule_presenter.orders.include?(order1) }
      And { schedule_presenter.orders.include?(order2) }
      And { schedule_presenter.orders.include?(order3) }
      And { schedule_presenter.orders.include?(order4) }
    end

    context 'when enable_schedule is false' do
      Given!(:order) { create :order, aasm_state: :paid, approved_at: approved_at, enable_schedule: false }
      Given(:schedule_presenter) { Print::OrderPrintSchedulePresenter.new(type: 'normal') }
      Then { schedule_presenter.orders.include?(order) == false }
    end

    context 'when search by number' do
      Given!(:order1) { create :order, aasm_state: :paid, approved_at: approved_at }
      Given!(:order2) { create :order, aasm_state: :packaged, approved_at: approved_at }
      Given(:schedule_presenter) { Print::OrderPrintSchedulePresenter.new(type: 'normal', number: order1.order_no) }
      Then { schedule_presenter.orders.include?(order1) }
      And { schedule_presenter.orders.include?(order2) == false }
    end
  end
end
