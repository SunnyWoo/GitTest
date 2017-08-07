require 'spec_helper'

RSpec.describe 'api/v3/coupons/show.json.jbuilder', :caching, type: :view do
  let(:coupon) { create(:coupon) }

  it 'renders coupon' do
    assign(:coupon, coupon)
    render
    expect(JSON.parse(rendered)).to eq(
      'coupon' => {
        'id' => coupon.id,
        'quantity' => coupon.quantity,
        'title' => coupon.title,
        'code' => coupon.code,
        'usage_count' => coupon.usage_count,
        'usage_count_limit' => coupon.usage_count_limit,
        'price_tier_id' => coupon.price_tier_id,
        'discount_type' => coupon.discount_type,
        'percentage' => coupon.percentage,
        'condition' => coupon.condition,
        'apply_target' => coupon.apply_target,
        'begin_at' => coupon.begin_at.as_json,
        'expired_at' => coupon.expired_at.as_json,
        'user_usage_count_limit' => coupon.user_usage_count_limit,
        'base_price_type' => coupon.base_price_type,
        'coupon_rules' => []
      }
    )
  end
end
