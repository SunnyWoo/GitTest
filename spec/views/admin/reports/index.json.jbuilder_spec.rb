require 'spec_helper'

RSpec.describe 'admin/reports/index.json.jbuilder', :caching, type: :view do
  let!(:report) { create(:report) }
  let(:reports) {
    q ||= { date_gteq: 7.day.ago.to_date, date_lteq: Date.today }
    q[:s] ||= 'date desc'
    search = Report.ransack(q)
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
    search.result(distinct: true).group('date').select(select)
  }

  it 'renders report' do
    assign(:reports, reports)
    render
    expect(JSON.parse(rendered)).to eq(
      'reports' => reports.map do |report|
        {
          'date' => report.date.as_json,
          'total_orders' => report.total_orders,
          'items_amount' => report.items_amount,
          'users_amount' => report.users_amount,
          'subtotal' => report.subtotal,
          'discount' => report.discount,
          'shipping_fee' => report.shipping_fee,
          'price' => report.price,
          'total_refund' => report.total_refund,
          'total' => report.total,
          'avg_order_price' => report.avg_order_price,
          'avg_per_user_price' => report.avg_per_user_price,
          'shipping_fee_discount' => report.shipping_fee_discount
        }
      end
    )
  end
end
