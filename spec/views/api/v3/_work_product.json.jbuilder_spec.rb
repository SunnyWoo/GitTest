require 'spec_helper'

RSpec.describe 'api/v3/_work_product.json.jbuilder', :caching, type: :view do
  let(:product) do
    create(:product_model)
  end

  it 'renders product' do
    render 'api/v3/work_product', product: product
    expect(JSON.parse(rendered)).to eq(
      'id' => product.id,
      'key' => product.key,
      'name' => product.name
    )
  end
end
