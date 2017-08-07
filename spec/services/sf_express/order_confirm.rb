require 'spec_helper'

describe SfExpress::OrderConfirm do
  describe '#execute' do
    context '#confirm', :vcr do
      Given(:order) { create(:shipping_to_tw_order) }
      Given { SfExpress::Order.new(order).execute }
      Given(:result) { SfExpress::OrderConfirm.new(order, 1).execute }
      Then { result['orderid'] == order.order_no }
      And { result['res_status'] == '操作成功' }
    end

    context '#cancel', :vcr do
      Given(:order) { create(:shipping_to_tw_order) }
      Given { SfExpress::Order.new(order).execute }
      Given(:result) { SfExpress::OrderConfirm.new(order, 2).execute }
      Then { result['orderid'] == order.order_no }
      And { result['res_status'] == '操作成功' }
    end
  end
end
