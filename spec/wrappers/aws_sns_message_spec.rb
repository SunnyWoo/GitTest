require 'spec_helper'

describe AwsSnsMessage do

  describe '#execute' do
    it 'init error' do
      expect{AwsSnsMessage.new}.to raise_error
    end

    it 'init error with device_type ' do
      expect{AwsSnsMessage.new('test message', 'mac').build}.to raise_error(AwsSnsMessage::InvalidDeviceTypeError)
    end

    it 'build iOS Message success' do
      expect(AwsSnsMessage.new('test message', 'iOS', deep_link: 'home', notification_id: 1).build).to eq(
        '{"APNS_SANDBOX":"{\"aps\":{\"alert\":\"test message\",\"sound\":\"default\",\"badge\":1,\"deep_link\":\"commandp-staging://home\",\"notification_id\":1}}"}'
      )
    end

    it 'build Android Message success' do
      expect(AwsSnsMessage.new('test message', 'Android', deep_link: 'home', notification_id: 1).build).to eq(
        '{"GCM":"{\"data\":{\"message\":\"test message\",\"deep_link\":\"commandp-staging://home\",\"notification_id\":1}}"}'
      )
    end

    it 'build All Message success' do
      expect(AwsSnsMessage.new('test message', 'all').build).to eq(
        '{"APNS_SANDBOX":"{\"aps\":{\"alert\":\"test message\",\"sound\":\"default\",\"badge\":1}}","GCM":"{\"data\":{\"message\":\"test message\"}}","default":"test message"}'
      )
    end
  end
end
