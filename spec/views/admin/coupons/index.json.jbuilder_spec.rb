require 'spec_helper'

RSpec.describe 'admin/coupons/index.json.jbuilder', :caching, type: :view do
  let!(:coupon) { create(:coupon) }
  let(:coupons) { Coupon.page(1) }

  it 'renders coupon' do
    assign(:coupons, coupons)
    render
    expect(JSON.parse(rendered)).to eq(
      'coupons' => [{
        'id' => coupon.id,
        'title' => coupon.title,
        'quantity' => coupon.quantity,
        'children_count' => coupon.children_count,
        'is_free_shipping' => coupon.is_free_shipping,
        'is_not_include_promotion' => coupon.is_not_include_promotion,
        'render_coupon' => view.render_coupon_code(coupon),
        'begin_at' => coupon.begin_at.as_json,
        'expired_at' => coupon.expired_at.as_json,
        'usage_count' => coupon.usage_count,
        'usage_count_limit' => coupon.usage_count_limit,
        'is_enabled' => coupon.is_enabled,
        'render_off_price' => view.render_off_price(coupon),
        'links' => {
          'edit' => {
            'path' => view.edit_admin_coupon_path(coupon, locale: I18n.locale)
          },
          'used_orders' => {
            'path' => view.used_orders_admin_coupon_path(coupon, locale: I18n.locale, format: 'csv')
          }
        }
      }],
      'meta' => {
        'pagination' => {
          'current_page' => coupons.current_page,
          'next_page' => coupons.next_page,
          'previous_page' => coupons.previous_page,
          'total_entries' => coupons.total_entries,
          'total_pages' => coupons.total_pages
        }
      }
    )
  end
end
