require 'spec_helper'

RSpec.describe 'api/v3/_banner.json.jbuilder', :caching, type: :view do
  let(:banner) { create(:banner) }

  it 'renders banner' do
    render 'api/v3/banner', banner: banner
    expect(JSON.parse(rendered)).to eq(
      'id' => banner.id,
      'name' => banner.name,
      'deeplink' => banner.deeplink,
      'image' => banner.image.url,
      'platforms' => banner.platforms,
      'url' => banner.url
    )
  end
end
