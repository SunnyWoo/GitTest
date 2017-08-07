require 'rails_helper'

RSpec.describe Print::OrdersController, type: :controller do
  Given(:factory) { create :factory }
  Given(:factory_member) { create :factory_member, factory: factory }

  before { sign_in factory_member }

  context '#splice_order' do
    Given(:order1) { create(:order, aasm_state: :paid) }
    Given(:order2) { create(:order, aasm_state: :paid) }
    before do
      allow(controller).to receive(:authorize).with(Order, :package?)
      Order.all.update_all(merge_target_ids: [order1.id, order2.id])
    end
    When { xhr :get, :splice_order, order_id: order1.id, format: :js }
    Then { assigns(:orders).map(&:id).sort == [order1.id, order2.id] }
  end

  context '#package_parting' do
    Given(:order) { create(:order, aasm_state: :paid) }
    before { allow(controller).to receive(:authorize).with(Order, :package?) }
    When { xhr :get, :package_parting, order_id: order.id, format: :js }
    Then { assigns(:order) == order }
  end
end
