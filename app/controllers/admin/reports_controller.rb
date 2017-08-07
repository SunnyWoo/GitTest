class Admin::ReportsController < AdminController
  before_action :check_platform, only: :index

  def index
    params[:q] ||= { date_gteq: 7.day.ago.to_date, date_lteq: Date.today }
    params[:q][:s] ||= 'date desc'
    @search = Report.ransack(params[:q])
    select = "date,
              count(order_id) as total_orders,
              sum(order_item_num) as items_amount,
              count(DISTINCT user_id) as users_amount,
              sum(subtotal) as subtotal,
              sum(coupon_price) as discount,
              sum(shipping_fee) as shipping_fee,
              sum(price) as price,
              sum(refund) as total_refund,
              sum(total) as total,
              (sum(total) / count(order_id)) as avg_order_price,
              (sum(total) / count(DISTINCT user_id)) as avg_per_user_price,
              sum(shipping_fee_discount) as shipping_fee_discount"
    @reports = @search.result(distinct: true).group('date').select(select)

    respond_to do |format|
      format.html
      format.json { render 'admin/reports/index' }
      format.csv do
        select += ", platform, country_code,
          sum(CASE user_role WHEN 'guest' THEN 1 ELSE 0 END) as vistor_total,
          (count(user_id) - sum(CASE user_role WHEN 'guest' THEN 1 ELSE 0 END)) as member_total
        "
        reports = @reports.group('platform, country_code').order('date ASC').select(select)
        send_data mark_csv_data(ReportService.to_csv(reports)),
                  filename: "OrderReport #{params[:q][:date_gteq]} ~ #{params[:q][:date_lteq]}.csv"
      end
    end
  end

  def update_report
    ReportService.execute_all_updates
    render nothing: true
  end

  def create
    MarketingReportWorker.perform_async(current_admin.id, params[:report])
    flash[:success] = "Please check email: #{current_admin.email} in 5 mins"
    respond_to do |format|
      format.js
    end
  end

  private

  def check_platform
    if params[:q] && params[:q][:platform_cont] && params[:q][:platform_cont] == 'Web'
      params[:q].delete(:platform_cont)
      params[:q][:platform_not_in] = %w(iOS android)
    end
  end
end
