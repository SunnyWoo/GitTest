require 'spec_helper'

describe AwsSns::CreatePlatformEndpoint, :vcr do

  let(:device) { create(:device) }

  describe '#execute' do
    it 'with null device' do
      expect{AwsSns::CreatePlatformEndpoint.new.execute}.to raise_error
    end

    it 'execute success' do
      obj = AwsSns::CreatePlatformEndpoint.new(device)
      allow(obj).to receive(:execute).and_return(return_message)
      expect(obj.execute).to eq(return_message)
    end

    it 'execute fail' do
      obj = AwsSns::CreatePlatformEndpoint.new(device)
      allow(obj).to receive(:execute).and_return(return_error_message)
      expect(obj.execute).to eq(return_error_message)
    end

    it 'return nil when REGION is china' do
      stub_env('REGION', 'china')
      obj = AwsSns::CreatePlatformEndpoint.new(device)
      expect(obj.execute).to be_nil
    end
  end

  def return_message
    return {:endpoint_arn=>"arn:aws:sns:ap-northeast-1:911990202915:endpoint/APNS/staging_apns/c6af8c6c-9708-3f2c-9a55-e8081909364f", :response_metadata=>{:request_id=>"70868bf3-ce2c-5979-89d2-c6ca87b09dd8"}}
  end

  def return_error_message
    return 'Invalid parameter: Token Reason: Endpoint arn:aws:sns:ap-northeast-1:911990202915:endpoint/APNS/staging_apns/c6af8c6c-9708-3f2c-9a55-e8081909364f already exists with the same Token, but different attributes'
  end
end


