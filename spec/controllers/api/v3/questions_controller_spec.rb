require 'rails_helper'

RSpec.describe Api::V3::QuestionsController, :api_v3, type: :controller do
  before { expect(controller).to receive(:doorkeeper_authorize!) }
  describe 'GET index' do
    Given!(:question_category) { create(:question_category) }
    Given!(:question) { create(:question, question_category: question_category) }
    When { get :index }
    Then { response.status == 200 }
    And { expect(response).to render_template('api/v3/question_categories/index') }
  end
end
