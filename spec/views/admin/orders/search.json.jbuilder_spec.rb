require 'spec_helper'

RSpec.describe 'admin/orders/search.json.jbuilder', :caching, type: :view do
  let!(:order) { create(:order) }
  let(:orders) { Order.page(1).decorate(with: Admin::OrderDecorator) }

  it 'renders order' do
    assign(:orders, orders)
    order.reload
    render
    expect(JSON.parse(rendered)).to eq(
      'orders' => [{
        'order_no' => {
          'order_no' => order.order_no,
          'link' => view.admin_order_path(order, locale: I18n.locale)
        },
        'remote_order_no' => order.remote_info['order_no'],
        'images' => order.order_items.map { |item| item.itemable_order_image.thumb.url },
        'aasm_state' => view.t("order.state.#{order.aasm_state}"),
        'created_at' => view.l(order.created_at, format: :long),
        'render_twd_price' => view.number_to_currency(order.render_twd_price),
        'shipping_way' => order.shipping_info_shipping_way,
        'country' => order.shipping_info_country,
        'platform' => order.platform,
        'render_cny_price' => view.number_to_currency(order.currency_price('CNY'), locale: 'zh-CN'),
        'default_currency' => Region.default_currency,
        'tags' => [],
        'flags' => []
      }],
      'meta' => {
        'pagination' => {
          'current_page' => orders.current_page,
          'next_page' => orders.next_page,
          'previous_page' => orders.previous_page,
          'total_entries' => orders.total_entries,
          'total_pages' => orders.total_pages
        }
      }
    )
  end
end
