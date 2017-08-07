# ReportMailer: 主要處理訂單報表(China)
# 請搭配 lib/tasks/report.rake 與 config/schedule.rb 來看
class ReportMailer < ApplicationMailer
  # 每天 9am, 6am 會執行 daily_orders_email, 會執行 ReportMailer.orders.deliver
  def orders
    today = Time.zone.today
    to = SiteSetting.find_by(key: 'OrdersReportReceiver').try(:value) || 'reports@commandp.com'
    subject = "[Reports][#{Region.region}] 訂單報表 #{today.strftime('%Y-%m-%d')}"

    days = [today]
    days.each do |day|
      serv = Report::OrderService.new(Order.by_month(day), locale)
      %i(default product finance).each do |style|
        attachments["reports_#{style}_#{day.strftime('%Y-%m')}.csv"] = {
          mime_type: 'text/csv',
          content: serv.to_csv(style: style)
        }
      end
    end

    mail to: to, subject: subject do |format|
      text = <<MSG
附上本月訂單
一般訂單報表 reports_default_YY-MM.csv
產品格式訂單報表 reports_product_YY-MM.csv
財務格式訂單報表 reports_finance_YY-MM.csv
MSG
      format.text { render text: text }
    end
  end

  # 每天 8:30am 會執行 report:last_month_orders_email 將上個月的報表寄出
  def range_orders(start_date, end_date)
    start_time = Time.zone.parse(start_date) # start_date example: 2015-09-01
    end_time = Time.zone.parse(end_date) # end_date example: 2015-12-01
    start_date_format = start_time.strftime('%Y-%m-%d')
    end_date_format = end_time.strftime('%Y-%m-%d')
    to = SiteSetting.find_by(key: 'OrdersReportReceiver').try(:value) || 'reports@commandp.com'
    subject = "[Reports][#{Region.region}] 訂單報表 #{start_date_format} ~ #{end_date_format}"

    orders = Order.between_times(start_time, end_time)
    serv = Report::OrderService.new(orders, locale)
    %i(default product finance).each do |style|
      attachments["reports_#{style}_#{start_date_format}_#{end_date_format}.csv"] = {
        mime_type: 'text/csv',
        content: serv.to_csv(style: style)
      }
    end

    mail to: to, subject: subject do |format|
      text = <<MSG
一般訂單報表 reports_default_YY-MM-DD_YY-MM-DD.csv
產品格式訂單報表 reports_product_YY-MM-DD_YY-MM-DD.csv
財務格式訂單報表 reports_finance_YY-MM-DD_YY-MM-DD.csv
MSG
      format.text { render text: text }
    end
  end

  # 特殊報表使用，只看傳入的 orders 參數來製作報表
  # 現在每個月第一天的早上6點會執行 report:monthly_sublimated_orders
  def specified_orders(orders, options = {})
    to = SiteSetting.find_by(key: 'OrdersReportReceiver').try(:value) || 'reports@commandp.com'
    sub_subject = options[:subject] || '訂單表報'
    subject = "[Reports][#{Region.region}] #{sub_subject}"
    serv = Report::OrderService.new(orders, locale)
    %i(default product finance).each do |style|
      attachments["reports_#{style}.csv"] = {
        mime_type: 'text/csv',
        content: serv.to_csv(style: style)
      }
    end
    mail to: to, subject: subject do |format|
      text = <<MSG
一般訂單報表 reports_default.csv
產品格式訂單報表 reports_product.csv
財務格式訂單報表 reports_finance.csv
MSG
      format.text { render text: text }
    end
  end

  # [工廠後台] 提供每日實際入倉的商品清單
  # 每天寄出當月的累計通過質檢的清單，不只有當日的
  def daily_print_items
    to = SiteSetting.find_by(key: 'DailyPrintItemReportReceiver').try(:value) || 'reports@commandp.com'
    day = Time.zone.today
    month = day.month
    year = day.year
    sub_subject = "#{day.strftime('%F')} 入倉商品清單 日報表"
    subject = "[Reports][#{Region.region.upcase}] #{sub_subject}"

    csv = Report::PrintItemService.new(year: year, month: month, locale: locale).execute
    file_name = "#{day.strftime('%F')}_daily_print_item_reports.csv"
    attachments[file_name] = {
      mime_type: 'text/csv',
      content: csv
    }

    text = <<MSG
每日實際入倉的商品清單
請參閱附件 #{file_name}
MSG

    mail to: to, subject: subject do |format|
      format.text { render text: text }
    end
  end

  # [工廠後台] 提供每個月採購與實銷月報表
  #
  #   为了这张票： https://ticket.commandp.com/issues/983
  #       当有start_date和end_date的时候，报表名称使用end_date所在的月份
  def monthly_print_items(start_date = nil, end_date = nil)
    to = SiteSetting.find_by(key: 'MonthlyPrintItemReportReceiver').try(:value) || 'reports@commandp.com'
    last_month = Time.zone.today.last_month
    last_month = end_date if start_date.present? && end_date.present?
    month = last_month.month
    year = last_month.year
    sub_subject = "#{year}-#{month} 採購與實銷 月報表"
    subject = "[Reports][#{Region.region.upcase}] #{sub_subject}"

    csv = Report::PrintItemService.new(year: year,
                                       month: month,
                                       start_at: start_date.try(:beginning_of_day),
                                       end_at: end_date.try(:end_of_day),
                                       locale: locale).execute
    attachments["#{year}_#{month}_monthly_print_item_reports.csv"] = {
      mime_type: 'text/csv',
      content: csv
    }

    text = <<MSG
每月採購與實銷的商品清單
請參閱附件 monthly_print_item_reports.csv
MSG

    mail to: to, subject: subject do |format|
      format.text { render text: text }
    end
  end

  def marketing_reports(file:, user:)
    to = user.try(:email) || 'reports@commandp.com'
    file_name = File.basename(file.path).match(/(.*)(?=\:)/).to_s
    attachments["#{file_name}.csv"] = file.read
    mail to: to, subject: '你要的行銷報表來囉' do |format|
      format.text { render text: "Hi, 這是你要的報表." }
    end
  ensure
    file.close
  end

  def b2b2c_order_report(file_path:)
    targets = SiteSetting.b2b2c_marketing_mails
    return SlackNotifier.send_msg("B2B2C訂單報表檔案遺失, #{file_path}") unless File.exist?(file_path)
    file = File.new(file_path)
    attachments[File.basename(file_path)] = file.read
    mail to: targets, subject: 'B2BC訂單報表' do |format|
      format.text { render text: "Hi, 這是你要的報表." }
    end
  ensure
    file.close
    File.delete(file_path) if File.exist?(file_path)
  end

  private

  def locale
    Region.china? ? :'zh-CN' : :'zh-TW'
  end
end
