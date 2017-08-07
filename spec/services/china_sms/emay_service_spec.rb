require 'spec_helper'

# 缺emay API return code文件測試失敗範例
describe ChinaSms::EmayService do
  context '#execute' do
    Given(:service) { ChinaSms::EmayService.new }
    Given(:content) { '【噗印商城】您的验证码是123456' }
    context 'with single phone number' do
      context 'returns status Ok when everything is fine' do
        Given(:target) { { phone: '0983060671', content: content } }
        before do
          expect_any_instance_of(ChinaSms::EmayService).to receive(:sms_fire).and_return(code: '0')
        end
        When(:result) { ChinaSms::EmayService.new.execute(target[:phone], target[:content]) }
        Then { expect(result[:status]).to eq 'Ok' }
        And { expect(result[:invalid_phones]).to be_blank }
      end
    end

    context 'check sms type' do
      it 'raise error when type is not allow' do
        expect { ChinaSms::EmayService.new(type: 'abc') }.to raise_error(ApplicationError)
      end

      it 'returns ok' do
        expect(ChinaSms::EmayService.new(type: 'captcha')).to be_truthy
        expect(ChinaSms::EmayService.new(type: 'marketing')).to be_truthy
      end
    end
  end
end
