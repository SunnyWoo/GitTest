require 'spec_helper'

# TODO: 需要再補詳細測試
describe Api::V3::MobilePagesController, :api_v3, type: :controller, signed_in: false do
  before do
    @mobile_page = create(:mobile_page, key: 'home', country_code: 'TW')
    create(:mobile_page, key: 'home', country_code: 'JP')
    create(:mobile_component, key: 'kv', mobile_page: @mobile_page)
  end

  describe 'GET /api/mobile_pages' do
    it 'return mobile_pages when country_code is TW' do
      get :index, access_token: access_token, country_code: 'TW'
      expect(response.status).to eq(200)
      expect(response).to render_template(:index)
      expect(assigns(:mobile_pages)[0][:country_code]).to eq(@mobile_page.country_code)
    end
  end

  describe 'GET /api/mobile_page/:key' do
    it 'return mobile_page when key is home country_code is TW' do
      get :show, access_token: access_token, key: 'home', country_code: 'TW'
      expect(response.status).to eq(200)
      expect(response).to render_template(:show)
      expect(assigns(:mobile_page)[:country_code]).to eq(@mobile_page.country_code)
    end

    it 'return 404 when key is xxx' do
      get :show, access_token: access_token, key: 'xxx'
      expect(response.status).to eq(404)
      expect(response_json['code']).to eq('RecordNotFoundError')
    end

    context 'with country_code EN' do
      context 'when key home not created' do
        it 'fallback to default country_code mobile_page' do
          get :show, access_token: access_token, key: 'home', country_code: 'EN'
          expect(response.status).to eq(200)
          expect(response).to render_template(:show)
          expect(assigns(:mobile_page)[:country_code]).to eq('TW')
        end
      end

      context 'when key home created' do
        before do
          create(:mobile_page, key: 'home', country_code: 'EN')
        end

        it 'returns en home mobile_page' do
          get :show, access_token: access_token, key: 'home', country_code: 'EN'
          expect(response.status).to eq(200)
          expect(response).to render_template(:show)
          expect(assigns(:mobile_page)[:country_code]).to eq('EN')
        end
      end
    end

    context 'when REGION is global' do
      before do
        create(:mobile_page, key: 'home', country_code: 'EN')
      end

      context 'with country_code HK' do
        it 'returns TW home mobile_page' do
          get :show, access_token: access_token, key: 'home', country_code: 'HK'
          expect(response.status).to eq(200)
          expect(response).to render_template(:show)
          expect(assigns(:mobile_page)[:country_code]).to eq('TW')
        end
      end

      context 'with country_code MO' do
        it 'returns TW home mobile_page' do
          get :show, access_token: access_token, key: 'home', country_code: 'MO'
          expect(response.status).to eq(200)
          expect(response).to render_template(:show)
          expect(assigns(:mobile_page)[:country_code]).to eq('TW')
        end
      end

      context 'with country_code MY' do
        it 'returns EN home mobile_page' do
          get :show, access_token: access_token, key: 'home', country_code: 'MY'
          expect(response.status).to eq(200)
          expect(response).to render_template(:show)
          expect(assigns(:mobile_page)[:country_code]).to eq('EN')
        end
      end

      context 'with country_code KR' do
        it 'returns EN home mobile_page' do
          get :show, access_token: access_token, key: 'home', country_code: 'KR'
          expect(response.status).to eq(200)
          expect(response).to render_template(:show)
          expect(assigns(:mobile_page)[:country_code]).to eq('EN')
        end
      end

      context 'with country_code CA' do
        it 'returns EN home mobile_page' do
          get :show, access_token: access_token, key: 'home', country_code: 'CA'
          expect(response.status).to eq(200)
          expect(response).to render_template(:show)
          expect(assigns(:mobile_page)[:country_code]).to eq('EN')
        end
      end

      context 'with country_code JP' do
        it 'returns JP home mobile_page' do
          get :show, access_token: access_token, key: 'home', country_code: 'JP'
          expect(response.status).to eq(200)
          expect(response).to render_template(:show)
          expect(assigns(:mobile_page)[:country_code]).to eq('JP')
        end
      end
    end
  end

  describe 'GET /api/mobile_page/:key/preview' do
    it 'return mobile_page when key is home country_code is TW' do
      get :preview, access_token: access_token, key: 'home', country_code: 'TW'
      expect(response.status).to eq(200)
      expect(response).to render_template(:preview)
    end
  end
end
