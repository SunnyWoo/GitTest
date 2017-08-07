require 'spec_helper'

RSpec.describe 'api/v3/_preview.json.jbuilder', :caching, type: :view do
  let(:preview) { create(:preview) }

  it 'renders preview' do
    render 'api/v3/preview', preview: preview
    expect(JSON.parse(rendered)).to eq(
      'id' => preview.id,
      # these used in _work.json.jbuilder
      'normal' => preview.image.url,
      'thumb' => preview.image.thumb.url,
      # these used in work previews api
      'key' => preview.key,
      'url' => preview.image.url,
      # these used in standardized work api
      'image_url' => preview.image.url,
      'position' => preview.position
    )
  end
end
