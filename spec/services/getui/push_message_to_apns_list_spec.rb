require 'spec_helper'

describe Getui::PushMessageToApnsList do
  let(:device) { create(:device) }

  describe '#execute' do
    context 'return error' do
      it 'when without params' do
        expect { Getui::PushMessageToApnsList.new.execute }.to raise_error(InvalidError)
      end

      it 'when without message', :vcr do
        push = Getui::PushMessageToApnsList.new(device_tokens: device.token)
        expect { push.execute }.to raise_error(InvalidError)
      end

      it 'when without device_tokens' do
        push = Getui::PushMessageToApnsList.new(message: 'Test')
        expect { push.execute }.to raise_error(InvalidError)
      end

      it 'when device_token error', :vcr do
        push = Getui::PushMessageToApnsList.new(message: 'Test', device_tokens: device.token)
        expect(push.execute['result']).to eq('OtherError')
      end
    end

    it 'return success', :vcr do
      push = Getui::PushMessageToApnsList.new
      push.message = 'Test Message'
      push.device_tokens = [device.token]
      allow(push).to receive(:execute).and_return(return_message)
      res = push.execute
      expect(res['result']).to eq('ok')
      expect(res['details'][device.token]).to eq('Success')
      expect(res['contentId']).not_to be_nil
    end
  end

  def return_message
    {
      'result' => 'ok',
      'details' => {
        device.token => 'Success'
      },
      'contentId' => 'OSAPNL-0803_o51JYsIKNJ705AcMhpiH66'
    }
  end
end
