require 'spec_helper'

describe PrintItemService do
  describe '.generate_qualified_report' do
    context 'return correct result' do
      Given!(:print_history_1) { create :print_history }
      Given!(:print_history_2) { create :print_history, :with_qualified }
      Given(:category_1) { print_history_1.print_item.product.category }
      Given(:category_2) { print_history_2.print_item.product.category }
      Given(:options) { { qualified_at_gteq: Time.zone.today.beginning_of_day, qualified_at_lteq: Time.zone.today.end_of_day } }
      Given(:result) { PrintItemService.generate_qualified_report(options) }
      Then { result[Time.zone.today.to_s] == { category_2.id => 1 } }
    end
  end
end
