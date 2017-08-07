require 'spec_helper'

describe SmsGetService do
  context '#execute' do
    Given(:service) { SmsGetService.new }
    context 'with single phone number' do
      context 'returns true when everything is fine' do
        Given(:target) { { phone: '0983060671', content: 'commandp台灣簡訊寄送測試！' } }
        before do
          result = { stats: true, error_code: '000' }.to_json
          expect_any_instance_of(SmsGetService).to receive(:sms_post_body).and_return(result)
        end
        When(:result) { SmsGetService.new.execute(target[:phone], target[:content]) }
        Then { expect(result[:status]).to eq 'Ok' }
        And { expect(result[:invalid_phones]).to be_blank }
      end

      context 'returns fail when send without number' do
        Given(:target) { { phone: '', content: 'commandp台灣簡訊寄送測試！' } }
        before do
          result = { stats: false, error_code: '001' }.to_json
          expect_any_instance_of(SmsGetService).to receive(:sms_post_body).and_return(result)
        end
        When(:result) { SmsGetService.new.execute(target[:phone], target[:content]) }
        Then { expect(result[:status]).to eq 'Fail' }
        And { expect(result[:message]).to eq '參數錯誤' }
        And { expect(result[:invalid_phones]).to be_blank }
      end
    end

    context 'with both valid and invalid phone numbers' do
      context 'returns ok and contains invalid numbers' do
        Given(:target) { { phones: '0983060671, 1234', content: 'commandp台灣簡訊寄送測試！' } }
        before do
          result = { stats: true, error_code: '000' }.to_json
          expect_any_instance_of(SmsGetService).to receive(:sms_post_body).and_return(result)
        end
        When(:result) { SmsGetService.new.execute(target[:phones], target[:content]) }
        Then { expect(result[:status]).to eq 'Ok' }
        And { expect(result[:invalid_phones]).to eq '1234' }
      end
    end

    context 'argument phones type' do
      context 'is acceptable with a string of an array' do
        Given(:target) { { phones: %w(0922333444 0955666777), content: 'commandp台灣簡訊寄送測試！' } }
        before do
          result = { stats: true, error_code: '000' }.to_json
          expect_any_instance_of(SmsGetService).to receive(:sms_post_body).and_return(result)
        end
        When(:result) { SmsGetService.new.execute(target[:phones], target[:content]) }
        Then { expect(result[:status]).to eq 'Ok' }
      end
    end
  end
end
