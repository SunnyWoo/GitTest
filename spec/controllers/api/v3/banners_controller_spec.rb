require 'spec_helper'

describe Api::V3::BannersController, type: :controller do
  describe '#index' do
    # default country code is US
    it 'returns available banners' do
      create(:banner, countries: %w(US))
      get :index, format: :json
      expect(response).to render_template('api/v3/banners/index')
    end

    it 'returns available banners' do
      create(:banner, begin_on: 1.day.ago, end_on: 1.day.from_now, countries: %w(US))
      get :index, format: :json
      expect(response).to render_template('api/v3/banners/index')
    end

    it 'did not returns unavailable banners' do
      create(:banner, begin_on: 2.days.ago, end_on: 1.day.ago, countries: %w(US))
      create(:banner, begin_on: 1.day.from_now, end_on: 2.days.from_now, countries: %w(US))
      get :index, format: :json
      expect(response).to render_template('api/v3/banners/index')
    end

    it 'did not returns banners in unavailable countries' do
      create(:banner, countries: %w(TW))
      get :index, format: :json
      expect(response).to render_template('api/v3/banners/index')
    end
  end
end
