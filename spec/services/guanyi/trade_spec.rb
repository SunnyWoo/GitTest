require 'spec_helper'

describe Guanyi::Trade do
  Given(:response_ok) do
    {
      success: true,
      requestMethod: "gy.erp.trade.get",
      orders: [{}],
      total: 1
    }
  end
  Given(:response_err) do
    {
      success: true,
      requestMethod: "gy.erp.trade.get",
      total: 0
    }
  end

  context '#get_by_platform_code' do
    context 'total bigger 1' do
      before { GuanyiService.any_instance.stub(:request).and_return(response_ok) }
      Then { Guanyi::Trade.new.get_by_platform_code('') == {} }
    end

    context 'total is 0' do
      before { GuanyiService.any_instance.stub(:request).and_return(response_err) }
      Given(:trade) { Guanyi::Trade.new }
      Then { expect { trade.get_by_platform_code('') }.to raise_error(GuanyiNotFoundError) }
    end
  end
end
