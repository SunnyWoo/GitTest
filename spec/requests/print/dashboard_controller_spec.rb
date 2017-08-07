require 'spec_helper'

RSpec.describe Print::DashboardController, type: :request do
  before do
    login_factory_member
  end

  let!(:other_model) { create(:product_model) }

  context '#index' do
    it 'should be successful when model of current factory exists' do
      get print_print_path
      expect(response).to be_success
    end

    it 'render 404 when model does not belongs to current factory' do
      get print_print_path, model_id: other_model.id
      expect(response.code.to_i).to eq 404
    end
  end

  context '#sublimate' do
    it 'should be successful when model of current factory exists' do
      get print_sublimate_path
      expect(response).to be_success
    end

    it 'render 404 when model does not belongs to current factory' do
      get print_sublimate_path, model_id: other_model.id
      expect(response.code.to_i).to eq 404
    end
  end

  context '#temp_shelf' do
    it 'should be successful when model of current factory exists' do
      get print_temp_shelves_path
      expect(response).to be_success
    end
  end
end
