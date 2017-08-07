require 'spec_helper'

RSpec.describe 'api/v3/product_models/des_images.json.jbuilder', :caching, type: :view do
  let(:product) do
    create(:product_model, :with_des_images)
  end

  let(:des_images) do
    product.description_images
  end

  it 'renders des_images' do
    assign(:des_images, des_images)
    render
    expect(JSON.parse(rendered)).to eq(
      'des_images' => des_images.map do |des|
        {
          'x1' => des.image.x1.url,
          'x2' => des.image.x2.url,
          'x3' => des.image.url
        }
      end
    )
  end
end
