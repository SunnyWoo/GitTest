require 'spec_helper'

RSpec.describe 'api/v3/_mobile_page.json.jbuilder', :caching, type: :view do
  let(:mobile_page) { create(:mobile_page, key: 'home') }

  it 'renders mobile page' do
    render 'api/v3/mobile_page', mobile_page: mobile_page
    expect(JSON.parse(rendered)).to eq(
      'id' => mobile_page.id,
      'key' => mobile_page.key,
      'begin_at' => mobile_page.begin_at.as_json,
      'close_at' => mobile_page.close_at.as_json,
      'page_type' => mobile_page.page_type,
      'components' => []
    )
  end
end
