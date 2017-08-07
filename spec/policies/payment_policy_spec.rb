require 'spec_helper'

describe PaymentPolicy do
end

describe PaymentPolicy::Scope do
  describe '#resolve' do
    it 'returns available payment methods' do
      scope = PaymentPolicy::Scope.new(double(country_code: 'TW'), Payment)
      expect(scope.resolve).to eq(Payment::COUNTRY_PAYMENT_MAPPING['TW'])
    end

    it 'returns default available payment methods if country_code is unknown' do
      scope = PaymentPolicy::Scope.new(double(country_code: 'unknown'), Payment)
      expect(scope.resolve).to eq(Payment::COUNTRY_PAYMENT_MAPPING['default'])
    end
  end
end
