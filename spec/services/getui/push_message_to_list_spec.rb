require 'spec_helper'

describe Getui::PushMessageToList do
  let(:device) { create(:device) }

  describe '#execute', :vcr do
    context 'return error' do
      it 'when without params' do
        expect { Getui::PushMessageToList.new.execute }.to raise_error(InvalidError)
      end

      it 'when without title' do
        push = Getui::PushMessageToList.new(client_ids: [device.getui_client_id])
        expect { push.execute }.to raise_error(InvalidError)
      end

      it 'when without client_id' do
        push = Getui::PushMessageToList.new(title: 'Test')
        expect { push.execute }.to raise_error(InvalidError)
      end

      it 'when client_id error' do
        push = Getui::PushMessageToList.new(title: 'Test', client_ids: [device.getui_client_id])
        expect(push.execute['result']).to eq('TokenMD5NoUsers')
      end
    end

    it 'return success' do
      push = Getui::PushMessageToList.new
      push.title = 'Test title'
      push.text = 'Test text'
      push.client_ids = [device.getui_client_id]
      allow(push).to receive(:execute).and_return(return_message)
      res = push.execute
      expect(res['result']).to eq('ok')
      expect(res['details'][device.getui_client_id]).to eq('successed_online')
      expect(res['contentId']).not_to be_nil
    end
  end

  def return_message
    {
      'result' => 'ok',
      'details' => {
        device.getui_client_id => 'successed_online'
      },
      'contentId' => 'OSL-0803_U8fyEKRLWr6l0ILiLNfxe5'
    }
  end
end
