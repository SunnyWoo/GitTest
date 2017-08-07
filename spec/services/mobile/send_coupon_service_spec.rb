require 'spec_helper'

describe Mobile::SendCouponService do
  Given(:notice) { '感谢您注册为噗印会员，您的专属5元优惠码 %{coupon_code}，下单立减5元。噗印中国官网上线，全场包邮大促！' }
  Given(:user) { create :user, mobile: 1_234_567_890 }
  Given(:coupon_notice) { create :coupon_notice, notice: notice }

  context '#initialize' do
    Given(:no_mobile_user) { create :user, mobile: nil }
    Given(:wrong_mobile_user) { create :user, mobile: '1asd143' }
    Then { expect { Mobile::SendCouponService.new(user, coupon_notice.id) }.not_to raise_error }
    And do
      expect { Mobile::SendCouponService.new(user, 'wrong id') }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context '#execute' do
    Given(:service) { Mobile::SendCouponService.new(user, coupon_notice.id) }
    context 'when failed' do
      Given(:bad_code) do
        JSON.parse({
          success: false,
          code: '3'
        }.to_json, symbolize_names: true)
      end
      Given(:err_msg) { "Send SMS Failed [emay-error-code:#{bad_code[:code]}]" }
      When { expect(ChinaSMS).to receive(:to).and_return(bad_code) }
      Then { expect { service.execute }.to raise_error ApplicationError, err_msg }
      And { user.reload.activities.last.key == 'mobile_send_coupon_code_fail' }
    end

    context 'when success' do
      Given(:good_code) do
        JSON.parse({
          success: true,
          code: '0'
        }.to_json, symbolize_names: true)
      end
      When { expect(ChinaSMS).to receive(:to).and_return(good_code) }
      Then { expect(service.execute).to eq good_code }
      And { user.reload.activities.last.key == 'mobile_send_coupon_code' }
    end
  end
end
