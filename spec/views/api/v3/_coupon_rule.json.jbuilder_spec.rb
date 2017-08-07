require 'spec_helper'

RSpec.describe 'api/v3/_coupon_rule.json.jbuilder', :caching, type: :view do
  let(:coupon_rule) { create(:coupon_rule, threshold_price_table: { 'USD' => 100 }) }

  it 'renders coupon_rule' do
    render 'api/v3/coupon_rule', coupon_rule: coupon_rule
    expect(JSON.parse(rendered)).to eq(
      'id' => coupon_rule.id,
      'quantity' => coupon_rule.quantity,
      'condition' => coupon_rule.condition,
      'threshold_prices' => coupon_rule.threshold.prices,
      'designer_ids' => coupon_rule.designer_ids,
      'product_model_ids' => coupon_rule.product_model_ids,
      'product_category_ids' => coupon_rule.product_category_ids,
      'work_gids' => coupon_rule.work_gids
    )
  end
end
