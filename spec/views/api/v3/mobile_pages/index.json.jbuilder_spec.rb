require 'spec_helper'

RSpec.describe 'api/v3/mobile_pages/index.json.jbuilder', :caching, type: :view do
  let(:mobile_page) { create(:mobile_page, key: 'home') }

  it 'renders mobile page' do
    assign(:mobile_pages, [mobile_page])
    render
    expect(JSON.parse(rendered)).to eq(
      'mobile_pages' => [{
        'id' => mobile_page.id,
        'key' => mobile_page.key,
        'begin_at' => mobile_page.begin_at.as_json,
        'close_at' => mobile_page.close_at.as_json,
        'page_type' => mobile_page.page_type,
        'components' => []
      }]
    )
  end
end
