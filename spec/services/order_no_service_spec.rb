require 'spec_helper'

describe OrderNoService do
  before do
    create(:order)
    create(:order, created_at: 1.day.ago)
  end
  Given(:order) { create :order }
  Given(:order_no_service) { OrderNoService.new(order) }

  context 'private#order_no_date' do
    Then { order_no_service.send(:order_no_date) == order.created_at.strftime('%Y%m%d')[2, 6] }
  end

  context 'private#order_serial_number' do
    Then { order_no_service.send(:order_serial_number) == '0002' }

    context 'when create a new before order#created_at' do
      When { create(:order, created_at: Time.zone.now.beginning_of_day) }
      Then { order_no_service.send(:order_serial_number) == '0003' }
    end
  end

  context '#random_code' do
    Then { order_no_service.send(:random_code, 0).nil? }
    Then { order_no_service.send(:random_code, 1).size == 1 }
    Then { order_no_service.send(:random_code, 2).size == 2 }
  end

  context '#country_code' do
    Then { order_no_service.send(:country_code) == order.billing_info_country_code }
  end
end
