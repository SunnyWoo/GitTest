require 'spec_helper'

RSpec.describe 'api/v3/mobile_pages/preview.json.jbuilder', :caching, type: :view do
  let(:mobile_page) { create(:mobile_page, key: 'home') }
  let(:mobile_page_preview) { create(:mobile_page_preview, mobile_page_id: mobile_page.id) }

  it 'renders mobile page' do
    assign(:mobile_page_preview, mobile_page_preview)
    render
    expect(JSON.parse(rendered)).to eq(
      'mobile_page' => {
        'id' => mobile_page_preview.mobile_page_id,
        'key' => mobile_page_preview.key,
        'begin_at' => mobile_page_preview.begin_at.as_json,
        'close_at' => mobile_page_preview.close_at.as_json,
        'page_type' => mobile_page_preview.page_type,
        'components' => []
      }
    )
  end
end
