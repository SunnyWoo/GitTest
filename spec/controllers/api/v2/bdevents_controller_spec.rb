require 'spec_helper'

describe Api::V2::BdeventsController, type: :controller do
  describe '#index' do
    it 'returns available events' do
      create(:bdevent)
      get :index
      expect(response_json['status']).to eq(true)
      expect(response_json['url']).not_to be_nil
    end

    it "returns don't have available events" do
      create(:bdevent, ends_at: Time.zone.now - 1.hour)
      get :index
      expect(response_json['status']).to eq(false)
      expect(response_json['message']).not_to be_nil
    end
  end
end
