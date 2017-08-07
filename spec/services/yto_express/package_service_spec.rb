require 'spec_helper'

RSpec.describe YtoExpress::PackageService do
  context '#attributes' do
    Given(:itemable) { instance_double("Work", name: 'work') }
    Given(:order_item) { instance_double("OrderItem", quantity: 2, itemable: itemable) }
    Given(:package) do
      instance_double('Pacakge',
                      package_no: 'P123TW',
                      shipping_info_name: 'gavin',
                      shipping_info_zip_code: '123',
                      shipping_info_phone: '17717392024',
                      shipping_info_state: '上海',
                      shipping_info_city: '上海市，闵行区',
                      shipping_info_address: '宜山路1618',
                      order_items: [order_item])
    end
    Given(:result) do
      {
        RequestOrder: {
          receiver: {
            name: 'gavin',
            postCode: '123',
            phone: '17717392024',
            mobile: "",
            prov: '上海',
            city: '上海市，闵行区',
            address: '宜山路1618'
          },
          items: {
            item: [{ itemName: 'work', number: 2, itemValue: '100' }]
          },
          txLogisticID: 'P123TW'
        }
      }
    end

    before do
      allow(order_item).to receive(:original_price_in_currency).with('CNY').and_return('100')
    end

    Given(:package_attributes) { YtoExpress::PackageService.new(package) }
    Then { package_attributes.attributes == result }
  end
end
