require 'spec_helper'

RSpec.describe 'api/v3/banners/index.json.jbuilder', type: :view do
  let(:banner) { create(:banner) }

  it 'renders banner' do
    assign(:banners, [banner])
    render
    expect(JSON.parse(rendered)).to eq(
      'banners' => [{
        'id' => banner.id,
        'name' => banner.name,
        'deeplink' => banner.deeplink,
        'image' => banner.image.url,
        'platforms' => banner.platforms,
        'url' => banner.url
      }]
    )
  end
end
