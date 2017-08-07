require 'spec_helper'

describe MobileVerifyService do
  context '#initialize' do
    Then { expect { MobileVerifyService.new(nil) }.to raise_error(MobileNumberError) }
    And { expect { MobileVerifyService.new('abde13') }.to raise_error(MobileNumberError) }
    And { expect { MobileVerifyService.new('18516107484') }.to_not raise_error }
    And { expect { MobileVerifyService.new(18_516_107_484) }.to_not raise_error }
  end

  Given(:mobile) { '1234567890' }
  Given(:obj) { MobileVerifyService.new(mobile) }
  Given(:code) { 234_567 }

  context '#retrieve_code' do
    before { expect(obj).to receive(:random_code).and_return(code) }
    Then { obj.redis.get(mobile).nil? } # when initialize, redis is empty
    And { obj.retrieve_code == code.to_s } # retrieve_code will always return a valid code
    And { obj.redis.get(mobile) == code.to_s } # after #retrieve_code redis would have this code
  end

  context '#expire_in' do
    before { expect(obj.redis).to receive(:ttl).with(mobile).and_return(130) }
    Then { obj.expire_in == 130.seconds }
  end

  context '#verify' do
    Given(:other_code) { 123_123 }
    before { expect(obj).to receive(:random_code).and_return(code) }
    Then { obj.verify(code) == true }
    And { obj.verify(code.to_s) == true }
    And { obj.verify(other_code) == false }
  end

  context '#cleanup' do
    before { expect(obj).to receive(:random_code).and_return(code) }
    When { obj.retrieve_code }
    Then { obj.redis.get(mobile) == code.to_s }

    context 'after cleanup' do
      When { obj.cleanup }
      Then { obj.redis.get(mobile).nil? }
    end
  end

  context '#send_code' do
    context 'for china' do
      before { stub_env('REGION', 'china') }
      context 'returns Ok' do
        Given(:redis) { obj.redis }
        Given(:logcraft) { Logcraft::Activity.where(key: 'mobile_code_sent').last }
        before { expect(obj).to receive(:random_code).and_return(code) }
        before { expect_any_instance_of(ChinaSms::EmayService).to receive(:execute).and_return(status: 'Ok') }
        before { expect(redis).to receive(:set).with(mobile, code.to_s, ex: MobileVerifyService::EXPIRE_SECONDS) }
        before do
          expect(redis).to receive(:set).with("#{mobile}:sns_sent", 'true', ex: MobileVerifyService::EXPIRE_SECONDS)
        end
        Then { expect(obj.send_code).to eq(status: 'Ok') }
        And { logcraft.extra_info['mobile'] == mobile }
      end

      context 'returns Error' do
        Given(:logcraft) { Logcraft::Activity.where(key: 'mobile_code_sent_error').last }
        before { expect_any_instance_of(ChinaSms::EmayService).to receive(:execute).and_return(status: 'Fail') }
        Then { expect { obj.send_code }.to raise_error(MobileNumberError) }
        And { logcraft.extra_info['mobile'] == mobile }
      end
    end

    context 'for global' do
      context 'returns Ok' do
        Given(:redis) { obj.redis }
        before { expect(obj).to receive(:random_code).and_return(code) }
        before { expect_any_instance_of(SmsKingService).to receive(:execute).and_return(status: 'Ok') }
        before { expect(redis).to receive(:set).with(mobile, code.to_s, ex: MobileVerifyService::EXPIRE_SECONDS) }
        before do
          expect(redis).to receive(:set).with("#{mobile}:sns_sent", 'true', ex: MobileVerifyService::EXPIRE_SECONDS)
        end
        Then { expect(obj.send_code).to eq(status: 'Ok') }
      end

      context 'returns Error' do
        Given(:logcraft) { Logcraft::Activity.where(key: 'mobile_code_sent_error').last }
        before { expect_any_instance_of(SmsKingService).to receive(:execute).and_return(status: 'Fail') }
        Then { expect { obj.send_code }.to raise_error(MobileNumberError) }
        And { logcraft.extra_info['mobile'] == mobile }
      end
    end

    context 'only send sns every 60 seconds' do
      before { expect(obj.redis).to receive(:get).with("#{mobile}:sns_sent").and_return('true') }
      before { expect_any_instance_of(SmsService).not_to receive(:execute) }
      Then { obj.send_code == true }
    end
  end
end
