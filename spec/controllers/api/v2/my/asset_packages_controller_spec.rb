require 'spec_helper'

describe Api::V2::My::AssetPackagesController, type: :controller do
  before { @request.env.merge! api_header(2) }
  let(:user) { create(:user) }

  describe '#index' do
    it 'returns my all asset packages' do
      available_package = create(:available_asset_package, countries: %w(US))
      user.asset_packages << available_package
      get :index, auth_token: user.auth_token
      expect(response).to render_template('api/v3/asset_packages/index')
    end
  end

  describe '#create' do
    it 'adds to favorite and returns added asset package' do
      package = create(:available_asset_package, countries: %w(US))
      count = package.downloads_count
      post :create, id: package.id, auth_token: user.auth_token
      expect(response).to render_template('api/v3/asset_packages/show')
      expect(user.asset_packages).to include(package)
      expect(package.reload.downloads_count).to eq(count + 1)
    end
  end

  describe '#destroy' do
    it 'adds to favorite and returns added asset package' do
      package = create(:available_asset_package, countries: %w(US))
      user.asset_packages << package
      delete :destroy, id: package.id, auth_token: user.auth_token
      expect(response).to render_template('api/v3/asset_packages/show')
      expect(user.asset_packages(true)).not_to include(package)
    end
  end
end
