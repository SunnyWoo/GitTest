class PaymentPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      # global Web V2站来自china ip的不能使用china的支付方式
      if Region.global? && country_code == 'CN'
        Payment::COUNTRY_PAYMENT_MAPPING['default']
      else
        Payment::COUNTRY_PAYMENT_MAPPING[country_code] ||
        Payment::COUNTRY_PAYMENT_MAPPING['default']
      end
    end
  end
end
