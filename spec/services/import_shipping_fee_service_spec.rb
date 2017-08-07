require 'spec_helper'

describe ImportShippingFeeService do
  describe 'import' do
    context 'import in china' do
      before { stub_env('REGION', 'china') }
      Given { ImportShippingFeeService.import }
      Then { Area.count == 8 }
      And { Province.count == 33 }
      And { ShippingFee::Normal.count == 129 }
      And { ShippingFee::Overweight.count == 129 }
    end

    context 'import in global' do
      before { stub_env('REGION', 'global') }
      Given { ImportShippingFeeService.import }
      Then { ShippingFee::Normal.count == 280 }
      And { ShippingFee::Overweight.count == 14 }
    end
  end
end
