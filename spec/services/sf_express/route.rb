require 'spec_helper'

describe SfExpress::Route do
  before do
    create(:shipping_to_tw_order)
  end

  describe '#execute' do
    context '#success', :vcr do
      Given(:result) { SfExpress::Route.new(Order.last, '994000397192').execute }
      Then { result['RouteResponse']['mailno'] == '994000397192' }
      And { result['RouteResponse']['Route'].size > 0 }
    end

    context '#fail', :vcr do
      Given(:result) { SfExpress::Route.new(Order.last, '994000397192sdasda').execute }
      Then { result.nil? }
    end
  end
end
