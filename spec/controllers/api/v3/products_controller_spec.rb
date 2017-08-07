require 'spec_helper'

describe Api::V3::ProductsController, :api_v3, type: :controller do
  let(:product_category) { create(:product_category, available: true) }
  let(:categories) { controller.instance_variable_get('@presenter').groups }
  describe '#index', signed_in: false do
    it 'returns available categories' do
      product_category
      get :index, access_token: access_token
      expect(response).to render_template('api/v3/products/index')
    end

    it 'does not return unavailable categories' do
      product_category.update(available: false)
      get :index, access_token: access_token
      expect(response).to render_template('api/v3/products/index')
      expect(categories).to eq([])
    end

    it 'returns available products' do
      create(:product_model, category: product_category, available: true)
      get :index, access_token: access_token
      expect(response).to render_template('api/v3/products/index')
    end

    it 'returns available products with scope: sellable and platform:website is false' do
      create(:product_model, category: product_category, available: true,
                             design_platform: { 'ios' => false, 'android' => false, 'website' => false })
      get :index, access_token: access_token, platform: 'website', scope: 'sellable'
      expect(categories).to eq([])
    end

    it 'returns available products with scope: sellable and platform:website is true' do
      create(:product_model, category: product_category, available: true,
                             design_platform: { 'ios' => false, 'android' => false, 'website' => true })
      get :index, access_token: access_token, platform: 'website', scope: 'sellable'
      expect(response).to render_template('api/v3/products/index')
    end

    it 'does not return available products' do
      create(:product_model, category: product_category, available: false)
      get :index, access_token: access_token
      expect(response).to render_template('api/v3/products/index')
    end

    it 'returns available products without params[:staff]' do
      create(:product_model, category: product_category, available: true, aasm_state: :staff)
      get :index, access_token: access_token
      expect(response).to render_template('api/v3/products/index')
      expect(categories).to eq([])
    end

    it 'returns staff_available products with params[:staff] = true' do
      product_model = create(:product_model, category: product_category, available: true, aasm_state: :staff)
      get :index, access_token: access_token, staff: true
      expect(response).to render_template('api/v3/products/index')
      expect(categories[0][1]).to eq([product_model])
    end

    def render_index
      get :index, access_token: access_token, scope: param_scope, platform: platform
    end

    context 'when scope' do
      before do
        @unavailable_category = create(:product_category, available: false)
        create(:product_model, category: @unavailable_category)

        @sellable_category = create(:product_category, available: true)
        create(:product_model, category: @sellable_category,
                               available: true,
                               design_platform: { 'ios' => true,
                                                  'android' => true,
                                                  'website' => true
                                                })

        @customizable_category = create(:product_category, available: true)
        create(:product_model, category: @customizable_category,
                               available: true,
                               customize_platform: { 'ios' => true,
                                                     'android' => true,
                                                     'website' => true
                                                   })
      end

      context 'is all' do
        let(:param_scope) { 'all' }

        context 'and platform is ios' do
          let(:platform) { 'ios' }
          it 'returns available product categories' do
            render_index
            expect(response).to render_template('api/v3/products/index')
            expect(categories.map{ |category, _products| category }).to include(@sellable_category, @customizable_category)
          end
        end

        context 'and platform is android' do
          let(:platform) { 'android' }
          it 'returns available product categories' do
            render_index
            expect(response).to render_template('api/v3/products/index')
            expect(categories.map{ |category, _products| category }).to include(@sellable_category, @customizable_category)
          end
        end

        context 'and platform is website' do
          let(:platform) { 'website' }
          it 'returns available product categories' do
            render_index
            expect(response).to render_template('api/v3/products/index')
            expect(categories.map{ |category, _products| category }).to include(@sellable_category, @customizable_category)
          end
        end
      end

      context 'is sellable' do
        let(:param_scope) { 'sellable' }
        context 'and platform is ios' do
          let(:platform) { 'ios' }
          it 'returns available product categories' do
            render_index
            expect(response).to render_template('api/v3/products/index')
            expect(categories.map{ |category, _products| category }).to include(@sellable_category)
          end
        end

        context 'and platform is android' do
          let(:platform) { 'android' }
          it 'returns available product categories' do
            render_index
            expect(response).to render_template('api/v3/products/index')
            expect(categories.map{ |category, _products| category }).to include(@sellable_category)
          end
        end

        context 'and platform is website' do
          let(:platform) { 'website' }
          it 'returns available product categories' do
            render_index
            expect(response).to render_template('api/v3/products/index')
            expect(categories.map{ |category, _products| category }).to include(@sellable_category)
          end
        end
      end

      context 'is customizable' do
        let(:param_scope) { 'customizable' }

        context 'and platform is ios' do
          let(:platform) { 'ios' }
          it 'returns available product categories' do
            render_index
            expect(response).to render_template('api/v3/products/index')
            expect(categories.map{ |category, _products| category }).to include(@customizable_category)
          end
        end

        context 'and platform is android' do
          let(:platform) { 'android' }
          it 'returns available product categories' do
            render_index
            expect(response).to render_template('api/v3/products/index')
            expect(categories.map{ |category, _products| category }).to include(@customizable_category)
          end
        end

        context 'and platform is website' do
          let(:platform) { 'website' }
          it 'returns available product categories' do
            render_index
            expect(response).to render_template('api/v3/products/index')
            expect(categories.map{ |category, _products| category }).to include(@customizable_category)
          end
        end
      end
    end
  end
end
