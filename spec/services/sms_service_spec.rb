require 'spec_helper'

describe SmsService do
  context '#initialize' do
    context 'raise NoSmsProviderError when povider is invalid' do
      Then { expect { SmsService.new(provider: :wtf).to raise_error(NoSmsProviderError) } }
    end
  end
end
