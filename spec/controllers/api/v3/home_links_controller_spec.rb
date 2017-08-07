require 'rails_helper'

RSpec.describe Api::V3::HomeLinksController, :api_v3, type: :controller do
  before { expect(controller).to receive(:doorkeeper_authorize!).and_call_original }

  Given!(:home_link) { create(:home_link) }

  describe 'GET /home_links', signed_in: false do
    When { get :index, access_token: access_token }
    Then { response.status == 200 }
    And { expect(response).to render_template('api/v3/home_links/index') }
  end
end
