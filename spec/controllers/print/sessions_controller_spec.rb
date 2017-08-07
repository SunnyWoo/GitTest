require 'spec_helper'

describe Print::SessionsController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:factory_member] }
  before { allow(controller).to receive(:set_locale) }

  context '#new' do
    When { get :new }
    Then { response.status == 200 }
  end

  context '#create' do
    Given(:factory_member) { create(:factory_member) }
    Given(:params) do
      { factory_member_sign_in: { code: factory_member.factory.code,
                                  username: factory_member.username,
                                  password: '12341234' } }
    end

    context 'sign_up success' do
      When { post :create, params }
      Then { controller.current_factory_member == factory_member }
    end
  end

  context '#destroy' do
    Given(:factory_member) { create(:factory_member) }
    before do
      allow(controller).to receive(:verify_signed_out_user)
      allow(controller).to receive(:current_factory_member).and_return(factory_member).at_least(:once)
    end

    When { delete :destroy }
    Then { expect(response).to redirect_to(new_factory_member_session_path) }
  end
end
