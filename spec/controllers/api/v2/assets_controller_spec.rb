require 'spec_helper'

describe Api::V2::AssetsController, type: :controller do
  describe '#index' do
    it 'returns assets' do
      package = create(:available_asset_package, countries: %w(US))
      create(:asset, package: package)
      get :index, asset_package_id: package.id, format: :json
      expect(response).to render_template('api/v3/assets/index')
    end
  end
end
