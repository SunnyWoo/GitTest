require 'spec_helper'

RSpec.describe 'api/v3/_work_category.json.jbuilder', :caching, type: :view do
  let(:category) do
    create(:product_category)
  end

  it 'renders category' do
    render 'api/v3/work_category', category: category
    expect(JSON.parse(rendered)).to eq(
      'id' => category.id,
      'key' => category.key,
      'name' => category.name
    )
  end
end
