require 'spec_helper'

describe StoreOrderPaymentNotificationService do
  Given(:store) { create :store }
  Given(:order) { create :paid_order, source: 2, channel: store.id }
  Given(:command_order) { create :paid_order, source: 0, channel: '布袋戲亡國' }
  context 'from China' do
    Given { stub_env('REGION', 'china') }
    context 'create activity when success' do
      Given(:service) { StoreOrderPaymentNotificationService.new(order.id) }
      Given { allow_any_instance_of(SmsService).to receive(:execute).and_return(status: 'Ok') }
      When(:result) { service.execute }
      Then { result.success? }
      And { order.activities.last.key == 'send_store_order_payment_notificiation_sms' }
    end

    context 'create fail activity when fail' do
      Given(:service) { StoreOrderPaymentNotificationService.new(order.id) }
      Given { allow_any_instance_of(SmsService).to receive(:execute).and_return(status: 'Fail') }
      When(:result) { service.execute }
      Then { !result.success? }
      And { order.activities.last.key == 'fail_to_send_store_order_payment_notificiation_sms' }
    end

    context 'fail NonStoreOrderError with none-store order' do
      Given(:service) { StoreOrderPaymentNotificationService.new(command_order.id) }
      When(:result) { service.execute }
      Then { !result.success? }
      And { result.error.code == 'NonStoreOrderError' }
    end

    context 'fail PhoneNumberMissingError with no-phone-provided order' do
      Given(:service) { StoreOrderPaymentNotificationService.new(order.id) }
      Given { order.billing_info.update_column :phone, nil }
      When(:result) { service.execute }
      Then { !result.success? }
      And { result.error.code == 'PhoneNumberMissingError' }
    end
  end
end
