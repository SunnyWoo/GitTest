require 'spec_helper'

describe Api::V2::ProductsController, type: :controller do
  describe '#index' do
    it 'returns available categories' do
      create(:product_category, available: true)
      get :index, format: :json
      expect(response).to render_template('api/v2/products/index')
      expect(controller.categories).to eq([])
    end

    it 'does not return unavailable categories' do
      category = create(:product_category, available: false)
      get :index, format: :json
      expect(response).to render_template('api/v2/products/index')
      expect(controller.categories).not_to include(category)
    end

    it 'returns available models' do
      category = create(:product_category, available: true)
      create(:product_model, category: category, available: true)
      get :index, format: :json
      expect(response).to render_template('api/v2/products/index')
      expect(controller.categories.map{ |c, _| c }).to include(category)
      expect(controller.categories.map{ |_, p| p }).to include(category.products)
    end

    it 'does not return available models' do
      category = create(:product_category, available: true)
      create(:product_model, category: category, available: false)
      get :index, format: :json
      expect(response).to render_template('api/v2/products/index')
      expect(controller.categories).not_to include(category)
    end

    it 'returns available products with scope: sellable, platform: website is false' do
      category = create(:product_category, available: true)
      create(:product_model, category: category, available: true,
                             design_platform: { 'ios' => false, 'android' => false, 'website' => false })
      get :index, scope: 'sellable', platform: 'website', format: :json
      expect(controller.categories).to eq([])
    end

    it 'returns available products with scope: sellable, platform: website is true' do
      category = create(:product_category, available: true)
      create(:product_model, category: category, available: true,
                             design_platform: { 'ios' => false, 'android' => false, 'website' => true })
      get :index, scope: 'sellable', platform: 'website', format: :json
      expect(controller.categories.map{ |c, _| c }).to include(category)
      expect(controller.categories.map{ |_, p| p }).to include(category.products)
      expect(controller.platform).to eq('website')
    end

    it 'returns available products when design_platform all false' do
      category = create(:product_category, available: true)
      create(:product_model, category: category, available: true,
                             design_platform: { 'ios' => false, 'android' => false, 'website' => false })
      get :index, format: :json
      expect(controller.categories.map{ |c, _| c }).to include(category)
      expect(controller.categories.map{ |_, p| p }).to include(category.products)
      expect(controller.platform).to eq(nil)
    end
  end
end
