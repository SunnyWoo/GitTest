require 'spec_helper'

describe Api::V2::AssetPackagesController, type: :controller do
  describe '#index' do
    # default country code is US
    it 'returns available asset packages' do
      create(:available_asset_package, countries: %w(US))
      get :index, format: :json
      expect(response).to render_template('api/v3/asset_packages/index')
    end

    it 'did return available asset packages' do
      create(:available_asset_package, begin_at: 2.days.ago, end_at: 1.day.ago, countries: %w(US))
      create(:available_asset_package, begin_at: 1.days.from_now, end_at: 2.day.from_now, countries: %w(US))
      get :index, format: :json
      expect(response).to render_template('api/v3/asset_packages/index')
    end

    it 'did not returns asset packages in unavailable countries' do
      create(:available_asset_package, countries: %w(TW))
      get :index, format: :json
      expect(response).to render_template('api/v3/asset_packages/index')
    end
  end
end
