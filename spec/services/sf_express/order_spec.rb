require 'spec_helper'

describe SfExpress::Order do
  Given(:order) { create(:shipping_to_tw_order) }
  Given do
    order.shipping_info.update(phone: '0910123456')
    allow(order).to receive(:order_no).and_return('1605115199999US')
  end

  describe '#execute' do
    context '#success', :vcr do
      Given(:result) { SfExpress::Order.new(order).execute }
      Then { result.key?('mailno') }
      And { result['orderid'] == order.order_no }
    end

    context '#fail', :vcr do
      Given { SfExpress::Order.new(order).execute }
      Given(:result) { SfExpress::Order.new(order).execute }
      Then { result['error'] == '重复下单TW' }
    end
  end

  context '#execute with adapter' do
    context '#success', :vcr do
      Given(:package) { create(:package) }
      Given!(:print_item) { create(:print_item, package_id: package.id) }
      Given(:adapter) { SfExpressAdapter.new(package) }
      Given(:result) { SfExpress::Order.new(adapter).execute }
      Given do
        print_item.order.shipping_info.update(phone: '0910123456')
        allow(package).to receive(:package_no).and_return('1605115100000US')
      end
      Then { result.key?('mailno') }
      And { result['orderid'] == package.package_no }
    end
  end
end
