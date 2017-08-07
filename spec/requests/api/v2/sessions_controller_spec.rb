require 'rails_helper'

RSpec.describe Api::V2::SessionsController, type: :request do
  let!(:user) { create(:user, email: 'test@commandp.me', password: 'commandp', password_confirmation: 'commandp') }
  context '#create' do
    it 'returns not found when parmas way unspecified' do
      data = { email: 'test@commandp.me', password_input: 'commandp' }
      post '/api/sign_in', data, api_header(2)
      expect(response.status).to eq 404
    end
  end
end
