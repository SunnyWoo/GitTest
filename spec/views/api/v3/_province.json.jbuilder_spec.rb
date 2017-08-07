require 'spec_helper'

RSpec.describe 'api/v3/_province.json.jbuilder', :caching, type: :view do
  let(:province) { create(:province) }

  it 'renders province' do
    render 'api/v3/province', province: province
    expect(JSON.parse(rendered)).to eq(
      'id' => province.id,
      'name' => province.name
    )
  end
end
