require 'spec_helper'

describe Api::V3::AssetPackagesController, type: :controller, signed_in: false do
  context '#show' do
    context 'returns ok with everything is fine' do
      Given(:package) { create :available_asset_package }
      When { get :show, access_token: access_token, id: package.id, format: :json }
      Then { response.status.to_i == 200 }
      And { expect(response).to render_template(:show) }
    end
  end
end
