require 'spec_helper'

describe Api::V1::WorksController, type: :controller do
  before do
    @request.env.merge! api_header(1)
    create(:work, :redeem)
  end

  let!(:work) { create(:work, :is_public) }

  context 'index' do
    it 'status 200' do
      get :index, page: 1, per_page: 20
      expect(response_json['works'].size).to eq(1)
    end
    it 'filter feature true get null' do
      get :index, feature: true
      expect(response_json['works'].size).to eq(0)
    end
    it 'filter feature true get one' do
      create(:work, :is_public, feature: true)
      get :index, feature: true
      expect(response_json['works'].size).to eq(1)
    end
    it 'filter feature false' do
      get :index, feature: false
      expect(response_json['works'].size).to eq(1)
    end
    it 'filter feature false' do
      create(:work, :is_public, feature: true)
      get :index, feature: 'all'
      expect(response_json['works'].size).to eq(2)
    end

    it 'return false filter artwork user name is CommandpUser' do
      work = create(:work, :is_public)
      work.user.update(name: 'CommandpUser')
      get :index, user_username: 'CommandpUser'
      expect(response_json['works'].size).to eq(0)
    end

    it 'return false filter artwork user of Designer user_name is CommandpUser' do
      designer = create(:designer, username: 'CommandpUser')
      create(:work, :is_public, user: designer)
      get :index, user_username: 'CommandpUser'
      expect(response_json['works'].size).to eq(1)
    end

    it 'sorted by new' do
      work = create(:work, :is_public, created_at: 1.year.from_now, name: 'newest')
      create(:work, :is_public)
      get :index, feature: 'all', sort: 'new'
      expect(response_json['works'].first['name']).to eq work.name
    end

    it 'sorted by popular' do
      work = create(:work, :is_public, impressions_count: 1000, name: 'hottest')
      poor_work = create(:work, :is_public, impressions_count: -1, name: 'poor work')
      get :index, feature: 'all', sort: 'popular'
      results = response_json['works']
      expect(results.first['name']).to eq work.name
      expect(results.last['name']).to eq poor_work.name
    end

    it 'return only specified product works with model_id provided' do
      iphone6_work = create(:work, :with_iphone6_model, work_type: 'is_public')
      get :index, feature: 'all', model_id: iphone6_work.product.id
      expect(response_json['works'].size).to eq(1)
      expect(response_json['works'].first['uuid']).to eq(iphone6_work.uuid)
    end

    it 'return only specified product works with model_key provided' do
      iphone6_work = create(:work, :with_iphone6_model, work_type: 'is_public')
      get :index, feature: 'all', model_key: iphone6_work.product.key
      expect(response_json['works'].size).to eq(1)
      expect(response_json['works'].first['uuid']).to eq(iphone6_work.uuid)
    end

    it 'returns all kinds of works without model_id provided' do
      create(:work, :with_iphone6_model, work_type: 'is_public')
      get :index, feature: 'all'
      expect(response_json['works'].size).to eq(2)
    end

    it 'returns correct work set with both sork and model_id provided' do
      newest_iphone6_work = create(:work, :with_iphone6_model, work_type: 'is_public', created_at: 1.year.from_now)
      iphone6_work = create(:work, :is_public, model_id: newest_iphone6_work.product.id)
      get :index, feature: 'all', model_id: iphone6_work.product.id, sort: 'new'
      results = response_json['works']
      expect(results.size).to eq 2
      expect(results.first['uuid']).to eq newest_iphone6_work.uuid
    end
  end

  context 'show' do
    it 'success when work is fine' do
      get :show, uuid: work.uuid
      expect(response).to be_success
    end

    it 'returns 404 when work not found' do
      get :show, uuid: '1234567'
      expect(response.status.to_i).to eq 404
    end
  end
end
