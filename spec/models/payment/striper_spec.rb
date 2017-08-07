require 'spec_helper'

describe Payment::Striper do

  describe 'paid?' do
    it 'return false if payment_id is blank' do
      order = create(:order, payment: 'stripe')
      expect(order.payment_object).not_to be_paid
    end

    it 'return true if have payment_id and retrieve' do
      allow_any_instance_of(StripeService).to receive(:retrieve).and_return(double)
      order = create(:order, payment: 'stripe')
      order.update(payment_id: 'blabal')
      expect(order.payment_object).to be_paid
    end

    it 'return false if have payment_id and retrieve raise error' do
      allow_any_instance_of(StripeService).to receive(:retrieve).and_raise(Stripe::InvalidRequestError.new('false','bla'))
      order = create(:order, payment: 'stripe')
      order.update(payment_id: 'blabal')
      expect(order.payment_object).not_to be_paid
    end
  end
end
