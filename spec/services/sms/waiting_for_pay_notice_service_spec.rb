require 'spec_helper'

describe Sms::WaitingForPayNoticeService do
  context '#initialize' do
    Given(:order) { create :order, payment: 'neweb/mmk', aasm_state: :waiting_for_payment }
    Given(:paid_order) { create :order, payment: 'neweb/mmk', aasm_state: :paid }
    Given(:mpp_order) { create :order, payment: 'neweb_mpp' }
    Then { expect { Sms::WaitingForPayNoticeService.new('no_order_id') }.to raise_error(ActiveRecord::RecordNotFound) }
    And { expect { Sms::WaitingForPayNoticeService.new(order.id) }.not_to raise_error }
    And { expect { Sms::WaitingForPayNoticeService.new(mpp_order.id) }.to raise_error(PaymentMethodNotAllowedError) }
    And { expect { Sms::WaitingForPayNoticeService.new(paid_order.id) }.to raise_error(PaymentStateError) }
  end

  context '#payment_content' do
    context 'paid with atm' do
      Given(:order) { create :order, payment: 'neweb/atm' }
      Then do
        order.payment_id = '1192302101210000'
        order.prepare_payment!
      end
      And do
        price = order.price.ceil
        msg = '您好，感謝您訂購“我印”客製化商品，您的繳款方式：銀行轉帳。請於繳費期限內完成付款，至ATM/網路銀行轉帳完成繳費，即可完成訂購手續。'
        msg += "您的訂單金額：#{price}元，您的轉帳代碼：007 第一銀行，繳費帳號：#{order.payment_id}，共16碼，謝謝您。"
        expect(Sms::WaitingForPayNoticeService.new(order.id).send(:payment_content)).to eq(msg)
      end
    end

    context 'paid with mmk' do
      Given(:order) { create :order, payment: 'neweb/mmk' }
      Then do
        order.payment_id = 'NW16020500340000'
        order.prepare_payment!
      end
      And do
        price = order.price.ceil
        msg = '您好，感謝您訂購“我印”客製化商品，您的繳款方式：超商繳費。請於繳費期限內完成付款。至超商選擇”ezPay 台灣支付”/“代碼輸入“，'
        msg += "完成繳費，即可完成訂購手續。您的訂單金額：#{price}元，您的繳費代碼：#{order.payment_id}，共16碼，謝謝您。"
        expect(Sms::WaitingForPayNoticeService.new(order.id).send(:payment_content)).to eq(msg)
      end
    end
  end

  context '#format_phone' do
    Given(:order) { create :order, payment: 'neweb/mmk', aasm_state: :waiting_for_payment }
    context 'with shipping info phone +886910123456' do
      Then do
        order.billing_info.update phone: '+886910123456'
      end
      And do
        expect(Sms::WaitingForPayNoticeService.new(order.id).send(:format_phone)).to eq('0910123456')
      end
    end

    context 'with shipping info phone 0910-123-456' do
      Then do
        order.billing_info.update phone: '0910-123-456'
      end
      And do
        expect(Sms::WaitingForPayNoticeService.new(order.id).send(:format_phone)).to eq('0910123456')
      end
    end
  end

  context '#execute' do
    Given(:order) { create :order, payment: 'neweb/mmk', aasm_state: :waiting_for_payment }

    context 'returns Ok' do
      before { allow_any_instance_of(SmsService).to receive(:execute).and_return(status: 'Ok') }
      When(:result) { Sms::WaitingForPayNoticeService.new(order.id).execute }
      Then { expect(result[:status]).to eq('Ok') }
      And { order.activities.where(key: 'send_sms').count == 1 }
    end

    context 'returns Fail' do
      before { allow_any_instance_of(SmsService).to receive(:execute).and_return(status: 'Fail', message: '參數錯誤') }
      When(:result) { Sms::WaitingForPayNoticeService.new(order.id).execute }
      Then { expect(result[:status]).to eq('Fail') }
      And { order.activities.where(key: 'send_sms_failed').count == 1 }
    end
  end
end
