require 'rails_helper'

RSpec.describe Api::V3::StandardizedWorksController, :api_v3, type: :controller, elasticsearch: true do
  render_views

  describe 'GET /api/standardized_works' do
    let!(:designer) { create(:designer) }
    let!(:tag) { create(:tag) }
    let!(:collection) { create(:collection) }
    let!(:work) { create(:standardized_work, :published, user: designer) }
    let!(:tag_work) { create(:standardized_work, :published, user: designer) }
    let!(:series_work) { create(:standardized_work, :published, user: designer) }

    before do
      collection.tags << tag
      tag_work.tags << tag
      # for elasticsearch add index
      work.__elasticsearch__.index_document
      tag_work.__elasticsearch__.index_document
      series_work.__elasticsearch__.index_document
      StandardizedWork.__elasticsearch__.refresh_index!
    end

    context 'returns correct work set when user signs in with basic params', signed_in: false do
      When { get :index, access_token: access_token, query: 'work', sort: 'new' }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/works/index') }
    end

    context 'return correct meta data when user signs in with page info params', signed_in: :normal do
      When { get :index, access_token: access_token, query: 'work', per_page: 20, page: 1 }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/works/index') }
    end

    context 'returns ok when user does not sign in', signed_in: false do
      When { get :index, access_token: access_token, query: 'work' }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/works/index') }
    end

    context 'returns ok when random sortred', signed_in: false do
      When { get :index, access_token: access_token, query: 'work', sort: 'random' }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/works/index') }
    end

    context 'returns correct data with searching product_key', signed_in: false do
      before do
        create(:standardized_work, :published, product: work.product)
        StandardizedWork.__elasticsearch__.refresh_index!
      end
      When { get :index, access_token: access_token, product_key: work.product_key }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/works/index') }
    end

    context 'returns correct data with searching category_id', signed_in: false do
      before do
        create(:standardized_work, :published, product: work.product)
        StandardizedWork.__elasticsearch__.refresh_index!
      end
      When { get :index, access_token: access_token, category_id: work.category.id }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/works/index') }
    end

    context 'use recommend sort', signed_in: false do
      Given!(:recommend_sort) { create :recommend_sort, sort: 'price_desc' }
      When { get :index, access_token: access_token, sort: 'recommend' }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
      And { JSON.parse(response.body)['meta']['request_query']['sort'] == recommend_sort.sort }
    end

    context 'returns correct data with searching tag name', signed_in: false do
      When { get :index, access_token: access_token, tag_name: tag.name }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
      And { JSON.parse(response.body)['works'].size == 1 }
      And { JSON.parse(response.body)['works'][0]['tags'][0]['name'] == tag.name }
    end

    context 'returns correct data with searching collection name', signed_in: false do
      When { get :index, access_token: access_token, collection_name: collection.name }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
      And { JSON.parse(response.body)['works'].size == 1 }
      And { JSON.parse(response.body)['works'][0]['id'] == tag_work.id }
    end
  end

  describe '#related', signed_in: false do
    let(:designer) { create(:designer) }
    context 'returns correct with correct standardized work uuid' do
      Given(:standardized_work) { create :standardized_work, :with_iphone6_model, user: designer }
      When { get :related, access_token: access_token, id: standardized_work.uuid }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/works/related') }
    end
  end

  describe '#show', signed_in: false do
    context 'returns correct with correct standardized work uuid' do
      Given(:standardized_work) { create :standardized_work, :with_iphone6_model }
      When { get :show, access_token: access_token, id: standardized_work.uuid }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/works/show') }
    end

    context 'returns correct with correct standardized work slug' do
      Given(:standardized_work) { create :standardized_work, :with_iphone6_model, slug: '3t6152ursd' }
      When { get :show, access_token: access_token, id: standardized_work.slug }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/works/show') }
    end
  end

  describe '#touch', signed_in: false do
    let(:designer) { create(:designer) }
    context 'increase impressions_count when touch standardized work' do
      Given(:standardized_work) { create :standardized_work, :with_iphone6_model, user: designer }
      When { patch :touch, access_token: access_token, id: standardized_work.uuid }
      Then { response.status == 200 }
      And { JSON.parse(response.body)['status'] == 'success' }
      And { standardized_work.reload.impressions_count == 1 }
    end
  end
end
