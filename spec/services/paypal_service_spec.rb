require 'spec_helper'

describe  PaypalService do
  before do
    CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
    CurrencyType.create(name: 'TWD', code: 'TWD', rate: 1)
  end

  context 'verify_with_paypal' do
    it 'success', :vcr do
      order = create(:order)
      order.update(payment_id: paypal_payment.id)
      paypal = PaypalService.new(order, payment_id: order.payment_id)
      expect(paypal.verify_with_paypal).to be true
    end

    it 'error don\' have payment_id', :vcr do
      order = create(:order, :with_paypal_create)
      paypal = PaypalService.new(order, payment_id: order.payment_id)
      expect(paypal.verify_with_paypal).to be false
    end

  end

  context "refund" do
    it 'total 99, success ' do
      order = create(:order, :with_paypal_create)
      order.reload
      paypal = PaypalService.new(order)
      order.refunds.create(refund_no: "943A16422630KPCI", amount: 99, note: "Test King!")
      #mock
      allow(paypal).to receive(:refund) { true }
      allow(order).to receive(:aasm_state) { :refunded }

      expect(paypal.refund(99)).to be true
      expect(order.errors.messages).to be {}
      expect(order.refunded?).to be true
      expect(order.refund_id).to be_nil
      expect(order.refunds.last.note).to eq "Test King!"
      expect(order.refunds.last.amount).to eq 99
    end

    it 'total $99, part_reufnd , $50' do
      order = create(:order, :with_paypal_create)
      order.reload
      paypal = PaypalService.new(order)

      #mock
      allow(paypal).to receive(:refund) { true }
      allow(order).to receive(:aasm_state) { :part_refunded }
      order.refunds.create(refund_no: "943A16422630KPCI", amount: 50, note: "Test King!")

      expect(paypal.refund(50)).to be true
      expect(order.errors.messages).to be {}
      expect(order.refund_id).to be_nil
      expect(order.part_refunded?).to be true
      expect(order.refunds.last.note).to eq "Test King!"
      expect(order.refunds.last.amount).to eq 50
    end

    it 'error , Refund total is more then order total ' do
      order = create(:order, :with_paypal_create)
      order.reload
      paypal = PaypalService.new(order)

      allow(paypal).to receive(:refund) { false }
      # allow(order.errors).to receive(:messages) { {:base => 'Refund total is more then order total.'} }
      expect(paypal.refund(9999)).to be false
      expect(order.errors.messages).not_to be_nil
    end

  end

  context 'create payment' do

    it 'success' do
      order = create(:order)

      allow(order).to receive(:price) { "99.00" }

      payment_attributes = {
        intent: "sale",
        payer: {
          payment_method: "credit_card",
          funding_instruments: [ {
            credit_card: {
              type: "visa",
              number: "4417119669820331",
              expire_month: "11", expire_year: "2018",
              cvv2: "874",
              first_name: "Joe", last_name: "Shopper",
              billing_address: {
                line1: "52 N Main ST",
                city: "Johnstown",
                state: "OH",
                postal_code: "43210", country_code: "US" } } } ] }
      }

      expect(order.payment_id).to be_nil

      paypal = PaypalService.new(order)
      # # mock
      allow(paypal).to receive(:create_payment_sale) { true }
      allow(order).to receive(:payment_id) { 'PAY-32H82147B8129442EKPDXNPI' }

      res = paypal.create_payment_sale(payment_attributes)
      expect(res).to be true
      expect(order.payment_id).not_to be_nil
    end
  end

end
