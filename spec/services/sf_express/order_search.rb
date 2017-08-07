require 'spec_helper'

describe SfExpress::OrderSearch do
  describe '#execute' do
    context '#search by mailno', :vcr do
      Given(:order) { create(:shipping_to_tw_order) }
      Given { SfExpress::Order.new(order).execute }
      Given(:result) { SfExpress::OrderSearch.new(order).execute }
      Then { result.key?('mailno') }
      And { result['orderid'] == order.order_no }
    end
  end
end
