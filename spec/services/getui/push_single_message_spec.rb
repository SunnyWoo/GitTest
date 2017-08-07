require 'spec_helper'

describe Getui::PushSingleMessage do

  let(:device) { create(:device) }

  describe '#execute', :vcr do
    context 'return error' do
      it 'when without params' do
        expect{Getui::PushSingleMessage.new.execute}.to raise_error(InvalidError)
      end

      it 'when without title' do
        push = Getui::PushSingleMessage.new(client_id: device.getui_client_id)
        expect{ push.execute }.to raise_error(InvalidError)
      end

      it 'when without client_id' do
        push = Getui::PushSingleMessage.new(title: 'Test')
        expect{ push.execute }.to raise_error(InvalidError)
      end

      it 'when client_id error' do
        push = Getui::PushSingleMessage.new(title: 'Test', client_id: device.getui_client_id)
        expect(push.execute['result']).to eq('TokenMD5NoUsers')
      end
    end

    it 'return success' do
      push = Getui::PushSingleMessage.new
      push.title = 'Test title'
      push.text = 'Test text'
      push.client_id = device.getui_client_id
      allow(push).to receive(:execute).and_return(return_message)
      res = push.execute
      expect(res['result']).to eq('ok')
      expect(res['status']).to eq('successed_online')
      expect(res['taskId']).not_to be_nil
    end
  end

  def return_message
    {
      "taskId" => "OSS-0803_pDKsoDFtXZ67OP2lzimeQ3",
      "result" => "ok",
      "status" => "successed_online"
    }
  end
end
