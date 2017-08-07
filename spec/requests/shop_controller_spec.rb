require 'spec_helper'

describe ShopsController, type: :request do
  let!(:work) { create(:standardized_work, aasm_state: :draft) }
  let!(:work2) { create(:standardized_work, :with_iphone6_model) }

  context 'index' do
    it 'status 302, product model unavailable' do
      work.product.update_column :available, false
      get shop_path(work.product, locale: :en)
      expect(response.status).to eq(404)
    end

    it 'status 200' do
      get shop_path(work2.product, locale: :en)
      expect(response.status).to eq(200)
      expect(response.body).to include("#{work2.product_name}")
      expect(response.body).to include(work2.name)
    end

    it 'all' do
      get shop_path(ProductModel.wildcard.slug, locale: :en)
      expect(response.status).to eq(200)
      expect(response.body).not_to include("#{work.product_name}")
      expect(response.body).to include("#{work2.product_name}")
    end
  end
end
