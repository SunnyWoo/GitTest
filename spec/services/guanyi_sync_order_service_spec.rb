
require 'spec_helper'

describe GuanyiSyncOrderService do
  Given(:trade_form) { double(GuanyiTradeForm, valid?: true, post!: { code: 'SO7024677467' }) }
  Given(:purchase_form) { double(GuanyiPurchaseForm, valid?: true, post!: { code: 'PAO7026346559' }) }
  Given(:order) { create(:order) }
  Given(:service) { GuanyiSyncOrderService.new(order) }

  context 'sync!' do
    before { expect(GuanyiTradeForm).to receive(:new) { trade_form } }
    before { expect(GuanyiPurchaseForm).to receive(:new) { purchase_form } }

    context 'success' do
      When { service.sync! }
      Then { service.order.guanyi_trade_code == 'SO7024677467' }
      And { service.order.guanyi_purchase_code == 'PAO7026346559' }
    end

    context 'errors' do
      Given(:trade_form) { double(GuanyiTradeForm, valid?: false, errors: { values: [%w(Wrong)] }) }
      Then { expect { service.sync! }.to raise_error(ArgumentError, 'Wrong') }
    end
  end
end
