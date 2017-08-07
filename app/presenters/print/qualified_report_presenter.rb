class Print::QualifiedReportPresenter
  attr_accessor :begin_date, :end_date

  def initialize(options)
    @begin_date = Date.parse(check_time(options[:qualified_at_gteq]))
    @end_date = Date.parse(check_time(options[:qualified_at_lteq]))
  end

  def product_categories
    report_category_ids = report.values.map(&:keys).uniq
    available_category_ids = ProductCategory.with_available_product.pluck(:id)
    ProductCategory.where(id: report_category_ids | available_category_ids)
  end

  def report
    PrintItemService.generate_qualified_report(search_options)
  end

  def csv_data
    PrintItemService.export_qualified_report(self)
  end

  def csv_file_name
    "質檢記錄報表#{@begin_date}_#{@end_date}"
  end

  def count_by_category(category_id)
    report.values.map { |r| r[category_id].to_i }.sum
  end

  private

  def search_options
    { qualified_at_gteq: @begin_date.beginning_of_day, qualified_at_lteq: @end_date.end_of_day }
  end

  def check_time(time)
    time.present? ? time : Time.zone.now.to_date.to_s
  end
end
