require 'rails_helper'

RSpec.describe Admin::ProductsController, :admin, type: :controller do
  let!(:product_category) { create(:product_category, available: true) }

  context '#index' do
    it "returns available categories" do
      get :index, format: :json
      expect(response).to render_template('admin/products/index')
      expect(assigns(:categories)).to eq(ProductModel.includes(:category).group_by(&:category).to_a)
    end

    it 'returns products with params[:staff] = true' do
      product_model = create(:product_model, category: product_category, available: true)
      get :index, format: :json
      expect(response).to render_template('admin/products/index')
      expect(assigns(:categories)[0][1]).to eq([product_model])
    end
  end
end
