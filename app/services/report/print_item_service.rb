# https://app.asana.com/0/9672537926113/120314219323226
# export print_itme 入倉 報表
# print_item qualified 過的就 算入倉

# by month
# Report::PrintItemService.new(month: 5).execute
# Report::PrintItemService.new(month: 5, year: 2015).execute
# by day
# Report::PrintItemService.new(day: '2016-01-01').execute

class Report::PrintItemService
  def initialize(args = {})
    @month = args.delete(:month)
    @year = args.delete(:year) || Time.zone.today.year
    @day = args.delete(:day)
    @start_at = args.delete(:start_at)
    @end_at = args.delete(:end_at)
    @locale = args.delete(:locale) || 'zh-CN'
    validates_args
    I18n.locale = @locale
  end

  def execute
    bom_head = %w(EF BB BF).map { |a| a.hex.chr }.join
    CSV.generate(bom_head) do |csv_row|
      csv_row << column_titles
      rows.each do |row|
        csv_row << row
      end
    end
  end

  def rows
    print_histories.map{ |ph| row(ph, ph.print_item) if ph.print_item }.compact
  end

  # shipped_at 之後可以改成 print_item.shipped_at
  def row(ph, print_item)
    order = print_item.order
    product = print_item.product
    per_itemable_price = [print_item.order_item.per_itemable_price('CNY'), 0].max
    shipped_at = print_item.shipped_at.present? ? print_item.shipped_at : order.try(:shipped_at)
    [
      order.order_no,
      print_item.timestamp_no,
      I18n.t("activerecord.attributes.order.payment_#{order.payment}"),
      order.try(:paid_at).try(:strftime, '%F'),
      I18n.t("order.state.#{order.aasm_state}"),
      print_item.order.try(:coupon).try(:title),
      product.category_name,
      product.name,
      product.factory_name,
      ph.try(:qualified_at).try(:strftime, '%F'),
      shipped_at.try(:strftime, '%F'),
      per_itemable_price
    ]
  end

  def column_titles
    if @locale == :'zh-CN'
      %w(订单编号 列印编号 付款方式 建立日期 状态 优惠券类型 产品分类名称 购买型号名称 工厂 质检日期 发货日期 销售金额(CNY))
    else
      %w(訂單編號 列印編號 付款方式 建立日期 狀態 優惠券類型 產品分類名稱 購買型號名稱 工廠 質檢日期 發貨日期 銷售金額(CNY))
    end
  end

  def print_histories
    includes = [print_item: [product: [:translations, category: :translations], order_item: :order]]
    print_histories = PrintHistory.includes(includes).order(:print_item_id)
    print_histories = if @month.present?
                        start_time, end_time = set_time
                        print_histories.where('(print_histories.qualified_at >= :start_time and print_histories.qualified_at <= :end_time) or
                                               (print_histories.shipped_at >= :start_time and print_histories.shipped_at <= :end_time)',
                                              start_time: start_time, end_time: end_time)
                      elsif @day.present?
                        print_histories.by_day(@day, field: :qualified_at)
                      end
    print_histories
  end

  def validates_args
    fail ApplicationError, "month or day can't be blank" if @month.nil? && @day.nil?
  end

  def set_time
    if @start_at && @end_at
      [@start_at, @end_at]
    else
      date = DateTime.new(@year, @month).in_time_zone
      [date.beginning_of_month, date.end_of_month]
    end
  end
end
