require 'spec_helper'

describe Api::V2::TemplatesController, type: :controller do
  before { request.env.merge! api_header(2) }
  Given!(:user) { create :user }
  Given(:product_model) { create :product_model }
  Given!(:work_template) { create :work_template, product: product_model, aasm_state: :published }

  context '#index' do
    context 'return published templates' do
      When { get :index, product_model_id: product_model.id, auth_token: user.auth_token }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/templates/index') }
      And { assigns(:templates).present? }
    end
  end
end
