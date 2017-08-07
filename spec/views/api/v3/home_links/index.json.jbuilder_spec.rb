require 'spec_helper'

RSpec.describe 'api/v3/home_links/index.json.jbuilder', type: :view do
  let(:home_link) { create(:home_link) }

  it 'renders home_link' do
    assign(:home_links, [home_link])
    render
    expect(JSON.parse(rendered)).to eq(
      'home_links' => [{
        'id' => home_link.id,
        'name' => home_link.name,
        'href' => home_link.href
      }]
    )
  end
end
