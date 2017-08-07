require 'spec_helper'

describe Print::QualifiedReportPresenter do
  context '#initialize' do
    context 'begin_date should be today if qualified_at_gteq is nil' do
      Given(:report_presenter) { Print::QualifiedReportPresenter.new({}) }
      Then { report_presenter.begin_date == Time.zone.today }
    end

    context 'end_date should be today if qualified_at_lteq is nil' do
      Given(:report_presenter) { Print::QualifiedReportPresenter.new({}) }
      Then { report_presenter.end_date == Time.zone.today }
    end
  end

  context '#product_categories' do
    context 'report should includes correct product category' do
      Given!(:print_history_1) { create :print_history }
      Given!(:print_history_2) { create :print_history, :with_qualified }
      Given(:category_1) { print_history_1.print_item.product.category }
      Given(:category_2) { print_history_2.print_item.product.category }
      Given(:options) { { qualified_at_gteq: Time.zone.today.to_s, qualified_at_lteq: Time.zone.today.to_s } }

      Given(:report_presenter) { Print::QualifiedReportPresenter.new(options) }
      Then { report_presenter.product_categories.include?(category_2) }
      And { report_presenter.product_categories.include?(category_1) == false }
      And { report_presenter.count_by_category(category_1.id) == 0 }
      And { report_presenter.count_by_category(category_2.id) == 1 }
    end
  end
end
