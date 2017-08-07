require 'rails_helper'

RSpec.describe Webhook::DeliveredMailsController, :type => :controller do
  context 'when request is valid' do
    it "should render bad request" do
      post :create
      expect(response.code).to eq '400'
      expect(response_json['message']).to eq "Invalid parameters"
    end
  end
end
