require 'spec_helper'

RSpec.describe 'api/v3/_home_link.json.jbuilder', :caching, type: :view do
  let(:home_link) { create(:home_link) }

  it 'renders home_link' do
    render 'api/v3/home_link', home_link: home_link
    expect(JSON.parse(rendered)).to eq(
      'id' => home_link.id,
      'name' => home_link.name,
      'href' => home_link.href
    )
  end
end
