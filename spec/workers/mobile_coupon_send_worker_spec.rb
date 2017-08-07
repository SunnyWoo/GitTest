require 'spec_helper'

describe MobileCouponSendWorker do
  it 'invokes Mobile::SendCouponService' do
    user = create(:user, mobile: 1_234_567_890)
    coupon_notice = create(:coupon_notice)
    expect_any_instance_of(Mobile::SendCouponService).to receive('execute').and_return({ code: 0 }.as_json)
    MobileCouponSendWorker.new.perform(user.id, coupon_notice.id)
  end
end
