require 'spec_helper'
describe OrderAutoCancelService do
  before do
    create(:order, :with_atm)
    create(:order, :with_atm, created_at: 7.day.ago)
  end

  context '#execute' do
    it 'success' do
      expect(Order.all.order('id ASC').map(&:aasm_state)).to eq(%w(waiting_for_payment waiting_for_payment))
      OrderAutoCancelService.new.execute
      expect(Order.all.order('id ASC').map(&:aasm_state)).to eq(%w(waiting_for_payment canceled))
    end
  end
end
