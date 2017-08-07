require 'spec_helper'

RSpec.describe Api::V3::ReviewsController, :api_v3, type: :controller do
  describe 'GET /api/reviews' do
    context 'when user did not sign in', signed_in: false do
      let(:work) { create :work, :with_reviews }
      let(:standardized_work) { create :standardized_work, :with_reviews }

      it 'returns right reviews data with all params provided' do
        get :index, work_id: work.uuid, access_token: access_token, reviews_count: 1
        expect(response.status).to eq 200
        expect(response).to render_template(:index)
      end

      it 'returns right reviews data with all params provided and params is slug' do
        get :index, work_id: work.slug, access_token: access_token, reviews_count: 1, reviews_order: 'asc'
        expect(response.status).to eq 200
        expect(response).to render_template(:index)
      end

      it 'returns right reviews data of standardized work with valid standardized_work_id' do
        get :index, standardized_work_id: standardized_work.uuid,
                    access_token: access_token, reviews_count: 1, reviews_order: 'asc'
        expect(response.status).to eq 200
        expect(response).to render_template(:index)
      end

      it 'returns reviews without params reviews_count' do
        get :index, work_id: work.uuid, access_token: access_token, reviews_order: 'asc'
        expect(response.status).to eq 200
        expect(response).to render_template(:index)
      end

      it 'returns 404 with incorrect or missing work_id' do
        get :index, work_id: 'jedi', access_token: access_token, reviews_order: 'asc'
        expect(response.status).to eq 404
      end

      it 'returns 404 with invalid standardized_work_id' do
        get :index, standardized_work_id: 'jedi', access_token: access_token, reviews_order: 'asc'
        expect(response.status).to eq 404
      end

      it 'returns right reviews data with all params provided and order is asc' do
        get :index, work_id: work.uuid, access_token: access_token, reviews_count: 2, reviews_order: 'asc'
        expect(response.status).to eq 200
        expect(response).to render_template(:index)
      end

      it 'returns right reviews data with all params provided and order is desc' do
        get :index, work_id: work.uuid, access_token: access_token, reviews_count: 2, reviews_order: 'desc'
        expect(response.status).to eq 200
        expect(response).to render_template(:index)
      end

      it 'returns right reviews data with all params provided and without order params' do
        get :index, work_id: work.uuid, access_token: access_token, reviews_count: 2
        expect(response.status).to eq 200
        expect(response).to render_template(:index)
      end

      it 'returns 0 reviews with reviews_after' do
        get :index, work_id: work.uuid, access_token: access_token, reviews_count: 2,
                    reviews_before: work.reviews.last.created_at
        expect(response.status).to eq 200
        expect(response).to render_template(:index)
      end

      it 'returns 2 reviews with reviews_after' do
        get :index, work_id: work.uuid, access_token: access_token, reviews_count: 2,
                    reviews_before: Date.new(2010, 2, 23)
        expect(response.status).to eq 200
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'POST /api/reviews' do
    let(:work) { create :work }
    let(:standardized_work) { create :standardized_work }
    context 'when user did sign in', signed_in: :normal do
      it 'returns ok when the review successfully created' do
        data = { body: 'User the source, Luke', star: 5 }
        count = work.reviews.count
        post :create, { work_id: work.uuid, access_token: access_token }.merge(data)
        expect(response.status).to eq 200
        expect(work.reload.reviews.count).to eq(count + 1)
        expect(response).to render_template(:show)
      end

      it 'returns ok when the review successfully created with params is slug' do
        data = { body: 'User the source, Luke', star: 5 }
        count = work.reviews.count
        post :create, { work_id: work.slug, access_token: access_token }.merge(data)
        expect(response.status).to eq 200
        expect(work.reload.reviews.count).to eq(count + 1)
        expect(response).to render_template(:show)
      end

      it 'returns ok when the review successfully created with valid standardized_work_id' do
        data = { body: 'User the source, Luke', star: 5 }
        count = standardized_work.reviews.count
        post :create, { standardized_work_id: standardized_work.uuid, access_token: access_token }.merge(data)
        expect(response.status).to eq 200
        expect(standardized_work.reload.reviews.count).to eq(count + 1)
        expect(response).to render_template(:show)
      end

      it 'returns 422 when the params body is nil' do
        data = { body: '', star: 3 }
        count = work.reviews.count
        post :create, { work_id: work.uuid, access_token: access_token }.merge(data)
        expect(response.status).to eq 422
        expect(work.reload.reviews.count).to eq(count)
      end
    end

    context 'when user did not sign in', signed_in: false do
      it 'returns 403' do
        data = { body: 'User the source, Luke', star: 5 }
        post :create, { work_id: work.uuid, access_token: access_token }.merge(data)
        expect(response.status).to eq 403
      end
    end

    context 'when user sing in as a guest', signed_in: :guest do
      it 'returns 403' do
        data = { body: 'User the source, Luke', star: 5 }
        count = work.reviews.count
        post :create, { work_id: work.uuid, access_token: access_token }.merge(data)
        expect(response.status).to eq 200
        expect(work.reload.reviews.count).to eq(count + 1)
        expect(response).to render_template(:show)
      end
    end
  end
end
