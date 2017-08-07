class PrintItemService
  # 質檢記錄報表
  # results:
  # {
  #   "2016-03-01" => {
  #     11 => 7,
  #      5 => 33,
  #      9 => 3,
  #      7 => 37,
  #      8 => 4,
  #      2 => 43,
  #     10 => 7
  #   },
  #   "2016-03-02" => {
  #      2 => 57,
  #     10 => 2,
  #     11 => 8,
  #      5 => 29,
  #      9 => 2,
  #      7 => 35
  #   }
  # }
  def self.generate_qualified_report(search)
    included_status = %w(print customer_service_retprint)

    timezone_abbr = Time.zone.now.strftime('%Z')

    results = PrintHistory.select("product_models.category_id, count(print_histories.id) print_count,
                                  date(print_histories.qualified_at AT TIME ZONE '#{timezone_abbr}') as date_qualified_at")
                          .joins(print_item: :product)
                          .where('print_histories.print_type in (?)', included_status)
                          .ransack(search).result
                          .group('product_models.category_id, date_qualified_at')

    results = results.group_by { |r| r.date_qualified_at.to_s }
    results.each do |date, result_arr|
      results[date] = result_arr.reduce({}) do |result, arr|
        result.merge(arr.category_id => arr.print_count)
      end
    end
    results
  end

  # 質檢記錄報表.csv
  def self.export_qualified_report(report_presenter)
    report, product_categories = report_presenter.report, report_presenter.product_categories
    return if report.blank?
    column_titles = %w(日期) + product_categories.map(&:name)
    CSV.generate do |csv|
      csv << column_titles
      (report_presenter.begin_date..report_presenter.end_date).each do |date|
        row = [date.to_s]
        date_report = report[date.to_s] || {}
        row += product_categories.map { |c| date_report[c.id] }
        csv << row
      end
      csv << ['subtotal'] + product_categories.map { |c| report_presenter.count_by_category(c.id) }
      csv << ['總計通過質檢品項', report.values.map(&:values).flatten.sum]
    end
  end
end
