require 'spec_helper'

RSpec.describe Api::V3::WorksController, :api_v3, type: :controller, elasticsearch: true do
  render_views

  describe 'GET /api/works' do
    before do
      designer = create(:designer)
      @work = create :work, :with_iphone6_model, impressions_count: 100, user: designer
      @series_work = create :work, :with_ipad_air2_model
      @redeem_wok = create :work, :redeem
      create :work, user: designer
      @tag = create(:tag)
      @collection = create(:collection)
      @tag_work = create :work, :with_iphone6_model, user: designer

      @collection.tags << @tag
      @tag_work.tags << @tag

      @tag_work.__elasticsearch__.index_document
      @work.__elasticsearch__.index_document
      # for elasticsearch add index
      Work.__elasticsearch__.refresh_index!
    end

    context 'returns correct work set when user signs in with basic params', signed_in: false do
      When { get :index, access_token: access_token, query: 'work', sort: 'popular' }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
    end

    context 'return correct meta data when user signs in with page info params', signed_in: :normal do
      When { get :index, access_token: access_token, query: 'work', per_page: 20, page: 1 }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
    end

    context 'returns ok when user does not sign in', signed_in: false do
      When { get :index, access_token: access_token, query: 'work' }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
    end

    context 'returns ok when random sortred', signed_in: false do
      When { get :index, access_token: access_token, query: 'work', sort: 'random' }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
    end

    context 'returns correct data with searching model_key', signed_in: false do
      before do
        create :work, :is_public, model: @work.product
        Work.__elasticsearch__.refresh_index!
      end
      When { get :index, access_token: access_token, product_key: @work.product_key }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
    end

    context 'returns correct data with searching category_id', signed_in: false do
      before do
        create :work, :is_public, model: @work.product
        Work.__elasticsearch__.refresh_index!
      end
      When { get :index, access_token: access_token, category_id: @work.category_id }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
    end

    context 'use recommend sort', signed_in: false do
      Given!(:recommend_sort) { create :recommend_sort, sort: 'price_desc' }
      When { get :index, access_token: access_token, sort: 'recommend', format: :json }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
      And { JSON.parse(response.body)['meta']['request_query']['sort'] == recommend_sort.sort }
    end

    context 'returns correct data with searching tag name', signed_in: false do
      When { get :index, access_token: access_token, tag_name: @tag.name }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
      And { JSON.parse(response.body)['works'].size == 1 }
      And { JSON.parse(response.body)['works'][0]['tags'][0]['name'] == @tag.name }
    end

    context 'returns correct data with searching collection name', signed_in: false do
      When { get :index, access_token: access_token, collection_name: @collection.name }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
      And { JSON.parse(response.body)['works'].size == 1 }
      And { JSON.parse(response.body)['works'][0]['id'] == @tag_work.id }
    end
  end

  describe 'GET /api/works/:uuid/related', signed_in: :normal do
    let!(:designer) { create(:designer) }
    let!(:work) { create :work, :with_iphone6_model, user: designer }
    let!(:series_work) { create :work, :with_ipad_air2_model }
    let!(:designer_work) { create :work, name: 'other name', user: designer, work_type: 'is_public' }
    context 'when the request works' do
      it 'returns the correct dat with all params provided' do
        get :related, access_token:    access_token,
                      id:              work.uuid,
                      series_count:    1,
                      designer_count:  1,
                      recommend_count: 1
        expect(response.status).to eq 200
        expect(response).to render_template(:related)
      end

      it 'includes series_work in user wishlist if user had added in' do
        user.create_wishlist
        user.wishlist.works << series_work
        get :related, access_token:    access_token,
                      id:              work.uuid,
                      series_count:    1,
                      designer_count:  1,
                      recommend_count: 1
        expect(response.status).to eq 200
        expect(response).to render_template(:related)
      end

      it 'returns data with no params provided' do
        get :related, access_token: access_token, id: work.uuid
        expect(response.status).to eq 200
        expect(response).to render_template(:related)
      end

      it 'returns 404 with inexistent work' do
        get :related, access_token: access_token, id: 'work_inexistent'
        expect(response.status).to eq 404
      end
    end
  end

  describe 'GET /api/works/:uuid', signed_in: :normal do
    Given!(:work) { create :work, :with_iphone6_model }

    context 'params is uuid' do
      When { get :show, access_token: access_token, id: work.uuid }
      Then { response.status == 200 }
      And { expect(response).to render_template(:show) }
    end

    context 'params is slug' do
      When { get :show, access_token: access_token, id: work.slug }
      Then { response.status == 200 }
      And { expect(response).to render_template(:show) }
    end
  end
end
