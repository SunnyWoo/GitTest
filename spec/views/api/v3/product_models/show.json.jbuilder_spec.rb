require 'spec_helper'

RSpec.describe 'api/v3/product_models/show.json.jbuilder', :caching, type: :view do
  let(:product) do
    create(:product_model)
  end

  it 'renders product' do
    assign(:product, product)
    render
    expect(JSON.parse(rendered)).to eq(
      'product_model' => {
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
        'padding_left' => product.padding_left.to_s,
        'editor_optimization_images' => {
          'overlay_image' => {
            'x1' => product.overlay_image.editor_optimization.x1.url,
            'x2' => product.overlay_image.editor_optimization.x2.url
          },
        },
        'specs' => [product].map do |spec|
          {
            'id' => spec.id,
            'name' => spec.name,
            'description' => spec.description,
            'width' => spec.width,
            'height' => spec.height,
            'dpi' => spec.dpi,
            'background_image' => spec.background_image.url,
            'overlay_image' => spec.overlay_image.url,
            'padding_top' => spec.padding_top.to_s,
            'padding_right' => spec.padding_right.to_s,
            'padding_bottom' => spec.padding_bottom.to_s,
            'padding_left' => spec.padding_left.to_s,
            '__deprecated' => 'WorkSpec is not longer available'
          }
        end
      }
    )
  end
end
