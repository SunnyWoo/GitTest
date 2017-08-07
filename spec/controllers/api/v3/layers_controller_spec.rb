require 'spec_helper'

describe Api::V3::LayersController, :api_v3, type: :controller do
  describe '#index' do
    context 'when current_user exists', signed_in: :normal do
      it 'returns layers' do
        work = create(:work, user: user)
        create(:layer, work: work)
        get :index, access_token: access_token, work_id: work.uuid
        expect(response).to render_template(:index)
      end

      it 'returns layers with params id slug' do
        work = create(:work, user: user)
        create(:layer, work: work)
        get :index, access_token: access_token, work_id: work.slug
        expect(response).to render_template(:index)
      end
    end
  end
end
