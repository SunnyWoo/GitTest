require 'spec_helper'

describe Api::V3::TemplatesController, :api_v3, type: :controller do
  Given(:product_model) { create :product_model }
  Given!(:work_template) { create :work_template, product: product_model, aasm_state: :published }

  context '#index', signed_in: :normal do
    context 'return published templates' do
      When { get :index, product_model_id: product_model.id, access_token: access_token }
      Then { response.status == 200 }
      And { expect(response).to render_template('api/v3/templates/index') }
      And { assigns(:templates).present? }
    end
  end
end
