require 'spec_helper'

describe EmbeddedCoupon do
  it 'can be created from coupon' do
    coupon = create(:coupon)
    embedded = coupon.embedded
    expect(embedded.id).to eq(coupon.id)
    expect(embedded.title).to eq(coupon.title)
    expect(embedded.code).to eq(coupon.code)
    expect(embedded.expired_at).to eq(coupon.expired_at)
    expect(embedded.prices).to eq('TWD' => 150, 'USD' => 5)
  end

  it 'is loadable and dumbable' do
    coupon = create(:coupon)
    embedded = coupon.embedded
    expect(EmbeddedCoupon.dump(embedded)).to eq(embedded.as_json)
    expect(EmbeddedCoupon.load(embedded.as_json).id).to eq(embedded.id)
  end
end
