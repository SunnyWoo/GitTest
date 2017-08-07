require 'spec_helper'

describe Users::RegistrationsController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }
  before { expect(controller).to receive(:set_locale) }

  describe '#new' do
    When { get :new }

    Then { response.status == 200 }
  end

  describe '#create' do
    Given(:email_data) do
      {
        user: { email: 'test@commandp.com',
                password: 'commandp',
                password_confirmation: 'commandp'
        },
        register_method: 'email'
      }
    end

    Given(:mobile_data) do
      {
        user: { mobile: '12345678901',
                password: 'commandp',
                password_confirmation: 'commandp'
        },
        register_method: 'mobile',
        code: '123456'
      }
    end

    context 'sign_up with email success' do
      When { post :create, email_data }

      Then { User.count == 1 }
      And { User.last.email == 'test@commandp.com' }
      And { response.status == 302 }
    end

    context 'sign_up with email fail' do
      When { post :create, email_data.merge(user: { password: 'commandperror' }) }

      Then { User.count == 0 }
      And { response.status == 200 }
    end

    context 'sign_up with mobile success' do
      When { allow_any_instance_of(MobileVerifyService).to receive(:verify).and_return(true) }
      When { post :create, mobile_data }

      Then { User.count == 1 }
      And { User.last.mobile == '12345678901' }
      And { response.status == 302 }
    end

    context 'sign_up with mobile fail' do
      When { allow_any_instance_of(MobileVerifyService).to receive(:verify).and_return(false) }
      When { post :create, mobile_data.merge(user: { password: 'commandper' }) }

      Then { User.count == 0 }
      And { response.status == 200 }
    end
  end
end
