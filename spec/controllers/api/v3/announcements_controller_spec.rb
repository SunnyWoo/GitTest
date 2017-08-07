require 'spec_helper'

describe Api::V3::AnnouncementsController, :api_v3, type: :controller do
  describe '/announcements', signed_in: false do
    it 'returns all announcements' do
      start_day = Time.zone.yesterday
      create(:announcement, default: true)
      create_list(:announcement, 3, default: false, starts_at: start_day, ends_at: start_day + 2.days)
      create(:announcement, default: false)
      get :index, access_token: token.token
      expect(response.status).to eq(200)
      expect(response).to render_template(:index)
    end
  end
end
