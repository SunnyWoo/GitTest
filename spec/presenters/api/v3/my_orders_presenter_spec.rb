require 'spec_helper'

describe Api::V3::MyOrdersPresenter do
  Given(:user) { create :user }
  Given(:presenter) { Api::V3::MyOrdersPresenter.new(user, scope) }
  Given(:scope) { nil }
  Given!(:o1) { create :order, user: user, viewable: true, aasm_state: 'paid' }
  Given!(:o2) { create :order, user: user, viewable: false }
  Given!(:o3) { create :order, user: user, viewable: true }
  Given!(:o4) { create :order, user: user, viewable: true, aasm_state: 'canceled' }
  Given!(:o5) { create :order, user: user, viewable: true, aasm_state: 'paid' }

  describe 'orders' do
    context 'scope with viewable only' do
      When(:orders) { presenter.orders.to_a }
      Then { expect(orders).to match_array [o1, o3, o4, o5] }
    end

    context 'given specified scope of state' do
      Given(:scope) { 'paid' }
      When(:orders) { presenter.orders.to_a }
      Then { expect(orders).to match_array [o1, o5] }
    end
  end

  describe '#etag' do
    context 'should be changed when' do
      context 'new order inserted' do
        Then do
          expect {
            create :order, user: user, viewable: true, aasm_state: 'paid'
          }.to change { presenter.etag }
        end
      end

      context 'any viewable order updated' do
        Then do
          expect {
            sleep(1); o3.touch
          }.to change { presenter.etag }
        end
      end

      context 'any viewable order deleted' do
        Then do
          expect {
            o5.destroy
          }.to change { presenter.etag }
        end
      end
    end

    context 'should be unchanged when' do
      context 'new non-viewable order inserted' do
        Then do
          expect {
            create :order, user: user, viewable: false, aasm_state: 'paid'
          }.not_to change { presenter.etag }
        end
      end

      context 'any viewable order updated' do
        Then do
          expect {
            o2.touch
          }.not_to change { presenter.etag }
        end
      end

      context 'any viewable order deleted' do
        Then do
          expect {
            o2.destroy
          }.not_to change { presenter.etag }
        end
      end
    end
  end
end
