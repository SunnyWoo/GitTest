require 'rails_helper'

RSpec.describe Api::V3::PreviewsController, :api_v3, type: :controller do
  describe '#index', signed_in: false do
    Given(:work) { create(:work) }
    When { get :index, access_token: access_token, work_id: work.uuid }
    Then { response.status == 403 }
  end

  describe '#index', signed_in: :guest do
    context 'when work is created by the user' do
      Given(:work) { create(:work, user: user) }
      When { get :index, access_token: access_token, work_id: work.uuid }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/previews/index') }
    end

    context 'when work is public' do
      Given(:work) { create(:work, :is_public) }
      When { get :index, access_token: access_token, work_id: work.uuid }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/previews/index') }
    end

    context 'when work is not found' do
      When { get :index, access_token: access_token, work_id: '404-not-found' }
      Then { response.status == 404 }
    end

    context 'when published standardized_work_id provided' do
      Given(:standardized_work) { create :standardized_work, :published }
      When { get :index, access_token: access_token, standardized_work_id: standardized_work.uuid }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/previews/index') }
    end

    context 'when unpublished standardized_work_id provided' do
      Given(:standardized_work) { create :standardized_work }
      When { get :index, access_token: access_token, standardized_work_id: standardized_work.uuid }
      Then { response.status == 404 }
    end

    context 'when invalid standardized_work_id provided' do
      When { get :index, access_token: access_token, standardized_work_id: '40404040404' }
      Then { response.status == 404 }
    end
  end

  describe '#index', signed_in: :normal do
    context 'when work is created by the user' do
      Given(:work) { create(:work, user: user) }
      When { get :index, access_token: access_token, work_id: work.uuid }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/previews/index') }
    end

    context 'when work is public' do
      Given(:work) { create(:work, :is_public) }
      When { get :index, access_token: access_token, work_id: work.uuid }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/previews/index') }
    end

    context 'when work is not found' do
      When { get :index, access_token: access_token, work_id: '404-not-found' }
      Then { response.status == 404 }
    end
  end
end
