require 'spec_helper'

describe PaymentDunService do
  Given(:sms_service) { SmsService.new(provider: :sms_get) }
  context '#initialize' do
    Given(:order) { create :order, payment: 'neweb/mmk', aasm_state: :waiting_for_payment }
    Given(:paid_order) { create :order, payment: 'neweb/mmk', aasm_state: :paid }
    Given(:mpp_order) { create :order, payment: 'neweb_mpp' }
    Then { expect { PaymentDunService.new('no_order_id', sms_service) }.to raise_error(ActiveRecord::RecordNotFound) }
    And { expect { PaymentDunService.new(order.id, sms_service) }.not_to raise_error }
    And { expect { PaymentDunService.new(mpp_order.id, sms_service) }.to raise_error(PaymentMethodNotAllowedError) }
    And { expect { PaymentDunService.new(paid_order.id, sms_service) }.to raise_error(PaymentStateError) }
    And { expect { PaymentDunService.new(order.id, 'sms_service') }.to raise_error(ServiceTypeError) }
  end

  context '#payment_content' do
    Given(:text) do
      '『您好，提醒您訂購“我印”客製化商品，還未繳款，您的商品在等您把它領回家唷，'\
            '請儘速至ATM/超商繳納費用，繳款期限到期仍未繳款，系統將自動取消訂單。'
    end
    context 'paid with atm' do
      Given(:order) { create :order, payment: 'neweb/atm' }
      Then do
        order.payment_id = '8825252'
        order.prepare_payment!
      end
      And do
        expect(PaymentDunService.new(order.id, sms_service).send(:payment_content))
          .to eq text + '您的繳款方式: 銀行代碼: 007, 付款帳戶: 8825252，謝謝您』'
      end
    end

    context 'paid with mmk' do
      Given(:order) { create :order, payment: 'neweb/mmk' }
      Then do
        order.payment_id = '8825252'
        order.prepare_payment!
      end
      And do
        expect(PaymentDunService.new(order.id, sms_service).send(:payment_content))
          .to eq text + '您的繳款方式: 超商繳費, 繳費代碼: 8825252，謝謝您』'
      end
    end
  end

  context '#execute' do
    Given(:order) { create :order, payment: 'neweb/mmk', aasm_state: :waiting_for_payment }

    context 'returns Ok' do
      before { allow_any_instance_of(SmsService).to receive(:execute).and_return(status: 'Ok') }
      When(:result) { PaymentDunService.new(order.id, sms_service).execute }
      Then { expect(result[:status]).to eq('Ok') }
      And { order.activities.where(key: 'send_sms').count == 1 }
    end

    context 'returns Fail' do
      before { allow_any_instance_of(SmsService).to receive(:execute).and_return(status: 'Fail', message: '參數錯誤') }
      When(:result) { PaymentDunService.new(order.id, sms_service).execute }
      Then { expect(result[:status]).to eq('Fail') }
      And { order.activities.where(key: 'send_sms_failed').count == 1 }
    end
  end
end
