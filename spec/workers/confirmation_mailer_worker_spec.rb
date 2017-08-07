require 'spec_helper'

describe ConfirmationMailerWorker do
  it 'invokes user#send_confirmation_email' do
    user = create :user
    expect_any_instance_of(User).to receive(:send_confirmation_token)
    ConfirmationMailerWorker.new.perform(user.id, nil)
  end
end
