require 'spec_helper'

describe ResetPasswordMailerWorker do
  it 'invokes user#send_password_reset_token' do
    user = create :user
    expect_any_instance_of(User).to receive(:send_password_reset_token)
    ResetPasswordMailerWorker.new.perform(user.id, nil)
  end
end
