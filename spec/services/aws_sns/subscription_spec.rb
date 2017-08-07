require 'spec_helper'

describe AwsSns::Subscription do

  describe '#execute' do
    it 'with params null' do
      expect{AwsSns::Subscription.new.execute}.to raise_error(AwsSnsService::InvalidEndpointArnError)
    end

    it 'execute success' do
      message = AwsSns::Subscription.new(endpoint_arn: 'xxxxxx')
      allow(message).to receive(:execute).and_return(return_message)
      expect(message.execute).to eq(return_message)
    end

    it 'return nil when REGION is china' do
      stub_env('REGION', 'china')
      message = AwsSns::Subscription.new(endpoint_arn: 'xxxxxx')
      expect(message.execute).to be_nil
    end
  end

  def return_message
    return {:message_id=>"169c363c-f020-57c4-ae40-7b05ed312b71", :response_metadata=>{:request_id=>"8012c7d2-3805-557f-b101-8aeb2515c9ca"}}
  end
end


