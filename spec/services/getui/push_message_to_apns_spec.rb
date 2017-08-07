require 'spec_helper'

describe Getui::PushMessageToApns do
  let(:device) { create(:device) }

  describe '#execute' do
    context 'return error' do
      it 'when without params' do
        expect { Getui::PushMessageToApns.new.execute }.to raise_error(InvalidError)
      end

      it 'when without message', :vcr do
        push = Getui::PushMessageToApns.new(device_token: device.token)
        expect { push.execute }.to raise_error(InvalidError)
      end

      it 'when without device_token' do
        push = Getui::PushMessageToApns.new(message: 'Test')
        expect { push.execute }.to raise_error(InvalidError)
      end

      it 'when device_token error', :vcr do
        push = Getui::PushMessageToApns.new(message: 'Test', device_token: device.token)
        expect(push.execute['result']).to eq('DeviceTokenError')
      end
    end

    it 'return success', :vcr do
      push = Getui::PushMessageToApns.new
      push.message = 'Test Message'
      push.device_token = device.token
      allow(push).to receive(:execute).and_return(return_message)
      res = push.execute
      expect(res['result']).to eq('ok')
      expect(res['taskId']).not_to be_nil
    end
  end

  def return_message
    {
      'taskId' => 'OSAPNS-0731_CfZccCnAc77E30Pr2WSdb1',
      'result' => 'ok'
    }
  end
end
