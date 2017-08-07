require 'rails_helper'

RSpec.describe Api::V3::HeaderLinksController, :api_v3, type: :controller do
  before { expect(controller).to receive(:doorkeeper_authorize!).and_call_original }

  Given!(:header_link) { create(:header_link) }

  context 'GET /header_links', signed_in: false do
    When { get :index, access_token: access_token }
    Then { response.status == 200 }
    And { expect(response).to render_template(:index) }
  end
end
