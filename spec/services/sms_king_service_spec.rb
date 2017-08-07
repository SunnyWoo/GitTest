require 'spec_helper'

describe SmsKingService do
  context '#execute' do
    Given(:service) { SmsKingService.new }
    context 'with single phone number' do
      context 'returns sending message when everything is fine' do
        Given(:target) { { phone: '0983060671', content: 'commandp台灣簡訊寄送測試！' } }
        before { expect_any_instance_of(SmsKingService).to receive(:sms_fire).and_return("kmsgid=123096601\n") }
        When(:result) { SmsKingService.new.execute(target[:phone], target[:content]) }
        Then { expect(result[:message]).to eq '已傳送' }
        And { expect(result[:invalid_phones]).to be_blank }
      end

      context 'returns failed message about number when send without number' do
        Given(:target) { { phone: '', content: 'commandp台灣簡訊寄送測試！' } }
        before { expect_any_instance_of(SmsKingService).to receive(:sms_fire).and_return(nil) }
        When(:result) { SmsKingService.new.execute(target[:phone], target[:content]) }
        Then { expect(result[:message]).to eq '未提供號碼' }
      end

      context 'returns failed message about empty content when send without content' do
        Given(:target) { { phone: '0933444555', content: '' } }
        before { expect_any_instance_of(SmsKingService).to receive(:sms_fire).and_return("kmsgid=-999989999\n") }
        When(:result) { SmsKingService.new.execute(target[:phone], target[:content]) }
        Then { expect(result[:message]).to eq '簡訊為空' }
      end
    end

    context 'with both valid and invalid phone numbers' do
      context 'returns ok and contains invalid numbers' do
        Given(:target) { { phones: '0983060671, 0933111444, 01234', content: 'commandp台灣簡訊寄送測試！' } }
        before { expect_any_instance_of(SmsKingService).to receive(:sms_fire).and_return("kmsgid=123168494\n\n") }
        When(:result) { SmsKingService.new.execute(target[:phones], target[:content]) }
        Then { expect(result[:message]).to eq '已傳送' }
        And { expect(result[:invalid_phones]).to eq '01234' }
      end
    end

    context 'argument phones type' do
      context 'is acceptable with a string of an array' do
        Given(:target) { { phones: %w(0922333444 0955666777), content: 'commandp台灣簡訊寄送測試！' } }
        before { expect_any_instance_of(SmsKingService).to receive(:sms_fire).and_return("kmsgid=123168494\n\n") }
        When(:result) { SmsKingService.new.execute(target[:phones], target[:content]) }
        Then { expect(result[:message]).to eq '已傳送' }
        And { expect(result[:invalid_phones]).to eq '' }
      end
    end
  end
end
