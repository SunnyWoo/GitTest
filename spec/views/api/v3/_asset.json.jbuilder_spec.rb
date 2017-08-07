require 'spec_helper'

RSpec.describe 'api/v3/_asset.json.jbuilder', :caching, type: :view do
  let(:asset) { create(:asset) }

  it 'renders asset' do
    render 'api/v3/asset', asset: asset
    expect(JSON.parse(rendered)).to eq(
      'id' => asset.id,
      'uuid' => asset.uuid,
      'type' => asset.type,
      'image' => asset.vector.url,
      'raster' => asset.raster.url,
      'vector' => asset.vector.url,
      'colorizable' => asset.colorizable
    )
  end
end
