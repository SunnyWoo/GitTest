require 'spec_helper'

describe Api::V3::AssetPackageCategoriesController, type: :controller, signed_in: false do
  context '#show' do
    it 'returns ok with everthing is fine' do
      category = create :asset_package_category
      get :show, id: category.id, access_token: access_token, format: :json
      expect(response.status.to_i).to eq 200
      expect(response).to render_template(:show)
    end
  end
end
