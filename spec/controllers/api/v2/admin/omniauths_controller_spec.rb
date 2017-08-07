require 'spec_helper'

describe Api::V2::Admin::OmniauthsController, type: :controller do
  before { @request.env.merge! api_header(2) }

  context 'GET :show' do
    context 'When omniauth is not found' do
      When { get :show, id: 123 }
      Then { response.status == 404 }
    end

    context 'Omniauth is found.' do
      Given(:omniauth) { create(:omniauth) }
      When { get :show, id: omniauth.oauth_token }
      Then { response.status == 200 }
      And { expect(response).to render_template(:show) }
    end
  end

  context 'DELETE :destroy' do
    Given!(:omniauth) { create(:omniauth) }
    When { delete :destroy, id: omniauth.oauth_token }
    Then { response.status == 200 }
    And { Omniauth.count == 0 }
  end
end
