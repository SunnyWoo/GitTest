require 'spec_helper'

describe Mobile::SendMarketingService do
  Given!(:user) { create :user, mobile: 1_234_567_890, confirmed_at: Time.zone.now }
  Given(:admin) { create :admin }
  Given(:message) { '11.11狂欢场！多达1111种手机照片定制方式！活动期间满100立即送50！' }
  Given(:options) do
    { 'sms_type' => 'emay', 'send_type' => 'test', 'test_phone' => '13970244523', 'content' => message }
  end

  context '#initialize' do
    Given(:marketing_sms_service) { Mobile::SendMarketingService.new(admin, options) }
    Then { marketing_sms_service.instance_values['message'] == message }
    And { marketing_sms_service.instance_values['text'] == "【#{Mobile::SendMarketingService::COMPANY}】亲爱的用户，#{message}回复TD退订" }
    And { marketing_sms_service.instance_values['test_phone'] == '13970244523' }
  end

  context '#execute' do
    context 'when failed' do
      Given(:bad_code) do
        JSON.parse({ success: false, code: '3' }.to_json, symbolize_names: true)
      end
      Given { expect(ChinaSMS).to receive(:to).and_return(bad_code) }
      Given(:err_msg) { "Send SMS Failed [emay-error-code:#{bad_code[:code]}]" }
      Then { expect { Mobile::SendMarketingService.new(admin, options).execute }.to raise_error ApplicationError, err_msg }
      Given(:marketing_sms_log) { Logcraft::Activity.where(key: :mobile_send_marketing).last }
      And { marketing_sms_log.message == "【#{Mobile::SendMarketingService::COMPANY}】亲爱的用户，#{message}回复TD退订" }
      And { marketing_sms_log.extra_info.fail_amount == 1 }
      And { marketing_sms_log.extra_info.error_message == err_msg }
    end

    context 'when success' do
      Given(:good_code) do
        JSON.parse({ success: true, code: '0' }.to_json, symbolize_names: true)
      end
      Given { expect(ChinaSMS).to receive(:to).and_return(good_code) }
      Given { Mobile::SendMarketingService.new(admin, options).execute }
      Given(:marketing_sms_log) { Logcraft::Activity.where(key: :mobile_send_marketing).last }
      Then { marketing_sms_log.message == "【#{Mobile::SendMarketingService::COMPANY}】亲爱的用户，#{message}回复TD退订" }
      And { marketing_sms_log.extra_info.success_amount == 1 }
      And { marketing_sms_log.extra_info.fail_amount.to_i == 0 }
    end
  end
end
