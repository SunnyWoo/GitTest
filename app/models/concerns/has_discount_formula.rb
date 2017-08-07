module HasDiscountFormula
  extend ActiveSupport::Concern

  module ClassMethods
    def has_discount_formula(rule_field, accessor = :discount_formula)
      class_eval <<-RUBY
        def #{accessor}
          @#{accessor} = Promotion::DiscountFormula.new(self.#{rule_field})
        end
      RUBY
    end
  end
end
