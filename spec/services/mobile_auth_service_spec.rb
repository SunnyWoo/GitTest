require 'spec_helper'

describe MobileAuthService do
  Given(:mobile) { '12345678901' }
  Given(:password_input) { 'password_input' }
  Given(:service) { MobileAuthService.new(mobile: mobile, password_input: password_input) }

  describe '#user' do
    context 'raise UserSignInError if no such user' do
      Then { expect { service.user }.to raise_error(UserSignInError) }
    end

    context 'with the user' do
      Given!(:user) { create(:user, mobile: mobile, password: password_input, password_confirmation: password_input) }
      Then { service.user == user }
      context 'with the wrong password' do
        Given(:service) { MobileAuthService.new(mobile: mobile, password_input: 'wrong_password') }
        Then { expect { service.user }.to raise_error(AuthenticationFailedError) }
      end
    end

    context 'when params is login' do
      Given!(:user) { create(:user, mobile: mobile, password: password_input, password_confirmation: password_input) }
      Given(:service_with_email) { MobileAuthService.new(login: mobile, password_input: password_input) }
      Then { service_with_email.user == user }
      context 'with the wrong password' do
        Given(:service_with_email_r) { MobileAuthService.new(login: mobile, password_input: 'wrong_password') }
        Then { expect { service_with_email_r.user }.to raise_error(AuthenticationFailedError) }
      end
    end
  end
end
