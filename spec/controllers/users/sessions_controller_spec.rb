require 'spec_helper'

describe Users::SessionsController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }
  before { allow(controller).to receive(:set_locale) }

  context '#new' do
    When { get :new }
    Then { response.status == 200 }
  end

  context '#create' do
    Given!(:user) do
      create(:user, email: 'test@commandp.me',
                    password: 'commandp', password_confirmation: 'commandp',
                    mobile: '18626058997')
    end

    Given(:email_data) do
      { user_sign_in: {
        login: 'test@commandp.me',
        password_input: 'commandp' }
      }
    end

    Given(:mobile_data) do
      { user_sign_in: {
        login: '18626058997',
        password_input: 'commandp' }
      }
    end

    context 'sign_up with email success' do
      When { post :create, email_data }
      Then { response.status == 302 }
      And { controller.current_user == user }
      And { expect(response).to redirect_to(root_path) }
      And { expect(user.activities.last.key).to eq('sign_in') }
    end

    context 'sign_up with email fail' do
      When { email_data[:user_sign_in][:password_input] = 'error' }
      When { post :create, email_data }
      Then { controller.current_user.nil? }
    end

    context 'sign_up with mobile success' do
      When { post :create, mobile_data }
      Then { response.status == 302 }
      And { controller.current_user == user }
      And { expect(response).to redirect_to(root_path) }
      And { expect(user.activities.last.key).to eq('sign_in') }
    end

    context 'sign_up with mobile fail' do
      When { mobile_data[:user_sign_in][:password_input] = 'error' }
      When { post :create, mobile_data }
      Then { controller.current_user.nil? }
    end
  end

  context '#destroy' do
    Given(:user) { create(:user) }
    before do
      allow(controller).to receive(:verify_signed_out_user)
      allow(controller).to receive(:current_user).and_return(user).at_least(:once)
      expect(controller).to receive(:log_with_current_user).with(user)
      expect(user).to receive(:create_activity).with(:sign_out)
    end

    When { delete :destroy }
    Then { expect(response).to redirect_to(root_path) }
  end
end
