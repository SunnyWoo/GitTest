require 'spec_helper'

describe MobileSignUpService do
  Given(:mobile) { '18516108494' }
  Given(:mobile_service) { MobileVerifyService.new(mobile) }
  Given(:code) { '123456' }
  Given(:password) { 'good_password123' }
  Given(:password_confirmation) { password }
  Given(:auth) do
    MobileSignUpService.new(
      mobile_service,
      code: code,
      password: password,
      password_confirmation: password_confirmation,
      confirmed_at: Time.zone.now
    )
  end

  context 'When verify fail' do
    When { expect(mobile_service).to receive(:verify).with(code).and_return(false) }
    Then { expect { auth.user }.to raise_error MobileVerificationFailedError }
  end

  context 'raises ActiveRecord::RecordInvalid if mobile has been used' do
    Given!(:user) { create(:user, mobile: mobile) }
    When { expect(mobile_service).to receive(:verify).with(code).and_return(true) }
    Then { expect { auth.user }.to raise_error ActiveRecord::RecordInvalid }
  end

  context 'get user' do
    When { expect(mobile_service).to receive(:verify).with(code).and_return(true) }
    Then { expect { auth.user }.to change(User, :count).by(1) }
    And { expect(auth.user.confirmed?).to be true }
  end
end
