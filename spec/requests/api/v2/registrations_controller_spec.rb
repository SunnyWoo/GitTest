require 'rails_helper'

RSpec.describe Api::V2::RegistrationsController, type: :request do
  context '#create' do
    it 'returns not found when params way is not provided' do
      data = { email: 'test@commandp.com', password: 'commandg', password_confirmation: 'commandg' }
      post '/api/sign_up', data, api_header(2)
      expect(response.status).to eq 404
    end
  end
end
