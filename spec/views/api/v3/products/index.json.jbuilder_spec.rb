require 'spec_helper'

RSpec.describe 'api/v3/products/index.json.jbuilder', :caching, type: :view do
  let(:unavailable_product_model) { build(:product_model, :unavailable) }
  let(:available_for_staff_product_model) { build(:product_model, :available_for_staff) }
  let(:available_for_customer_product_model) { build(:product_model, :available_for_customer) }
  let!(:product_category) do
    create(:product_category, products: [
      unavailable_product_model,
      available_for_staff_product_model,
      available_for_customer_product_model
    ])
  end

  def product_model_json(product)
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
      'padding_left' => product.padding_left.to_s,
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
  end

  it 'renders product_category' do
    options = {
      scope: 'sellable',
      platform: 'ios',
      available: 'available'
    }
    presenter = Api::V3::ProductListPresenter.new(options)
    allow(view).to receive(:platform).and_return('ios')
    allow(view).to receive(:scope).and_return('sellable')
    allow(presenter).to receive(:products).and_return(ProductModel.available.includes(:category))
    assign(:presenter, presenter)
    render
    expect(JSON.parse(rendered)).to eq(
      'categories' => [{
        'id' => product_category.id,
        'key' => product_category.key,
        'name' => product_category.name,
        'images' => {
          "s80"=>nil,
          "s160"=>nil
        },'models' => [
          product_model_json(available_for_customer_product_model)
        ]
      }],
      'meta' => {
        'category_count' => 1,
        'product_model_count' => 1,
        'platform' => 'ios',
        'scope' => 'sellable'
      }
    )
  end
end
