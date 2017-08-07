require 'spec_helper'

describe PingppService do
  before do
    CurrencyType.create(name: 'CNY', code: 'CNY', rate: 5)
    CurrencyType.create(name: 'TWD', code: 'TWD', rate: 1)
  end

  Given(:pingpp) { YAML.load(File.read("#{Rails.root}/spec/fixtures/pingpp_object.yml")) }
  Given(:pingpp_refund) { YAML.load(File.read("#{Rails.root}/spec/fixtures/pingpp_refund_object.yml")) }

  describe '#refund' do
    before { expect(Pingpp::Charge).to receive(:retrieve).and_return(pingpp) }
    before { expect(pingpp.refunds).to receive(:create).and_return(pingpp_refund) }
    context 'with pingpp alipay' do
      Given(:order) { create(:order, :with_pingpp_alipay) }
      Given(:pinpp) { PingppService.new(order) }
      When { pinpp.refund(1) }
      Then { order.refunding? }
      And { order.errors.messages[:failure_msg].present? }
    end

    context 'float problem: 39.2 * 100 will be 3920.0000000005' do
      Given(:order) { create(:order, :with_pingpp_alipay) }
      Given(:pinpp) { PingppService.new(order) }
      before { allow(pingpp).to receive(:amount).and_return(3920) }
      When { pinpp.refund('39.2') }
      Then { order.refunding? }
    end

    context 'with pingpp wx' do
      Given(:order) { create(:order, :with_pingpp_wx) }
      Given(:pinpp) { PingppService.new(order) }
      When { pinpp.refund(1) }
      Then { order.refunding? }
      And { order.refund_id.nil? }
      And { order.errors.messages[:failure_msg].blank? }
    end

    context 'error, Refund total is more then order total' do
      Given(:order) { create(:order, :with_pingpp_wx) }
      Given(:pinpp) { PingppService.new(order) }
      When { pinpp.refund(100) }
      Then { raise_error Pingpp::InvalidRequestError }
    end
  end

  describe 'refund_success' do
    context 'part refund' do
      Given(:order) { create(:order, :with_pingpp_alipay) }
      Given { allow(order).to receive(:price_after_refund).and_return(79) }
      When { PingppService.refund_success(order, '123456789', 20, 'Pingpp refund') }
      Then { order.reload.part_refunded? }
      And { order.refunds.last.refund_no == '123456789' }
      And { order.refunds.last.note == 'Pingpp refund' }
    end

    context 'total refund' do
      Given(:order) { create(:order, :with_pingpp_alipay) }
      Given { allow(order).to receive(:price_after_refund).and_return(0) }
      When { PingppService.refund_success(order, '123456789', 99, 'Pingpp refund') }
      Then { order.reload.refunded? }
      And { order.refunds.last.refund_no == '123456789' }
      And { order.refunds.last.note == 'Pingpp refund' }
    end
  end
end
