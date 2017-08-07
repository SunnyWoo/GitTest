require 'spec_helper'

RSpec.describe 'api/v3/product_models/index.json.jbuilder', :caching, type: :view do
  let!(:product) { create(:product_model) }
  let!(:unavailable_product) { create :unavailable_product_model }
  let(:products) { ProductModel.available.page(1) }

  it 'renders notification' do
    assign(:products, products)
    render
    expect(JSON.parse(rendered)).to eq(
      'products' => [
        {
          'id' => product.id,
          'key' => product.key,
          'name' => product.name,
          'description' => product.description,
          'prices' => product.prices,
          'customized_special_prices' => product.customized_special_prices,
          'design_platform' => product.design_platform,
          'customize_platform' => product.customize_platform,
          'placeholder_image' => product.placeholder_image.url,
          'width' => product.width,
          'height' => product.height,
          'dpi' => product.dpi,
          'background_image' => product.background_image.url,
          'overlay_image' => product.overlay_image.url,
          'padding_top' => product.padding_top.to_s,
          'padding_right' => product.padding_right.to_s,
          'padding_bottom' => product.padding_bottom.to_s,
          'padding_left' => product.padding_left.to_s
        }
      ]
    )
  end
end
