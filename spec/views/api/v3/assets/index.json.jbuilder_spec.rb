require 'spec_helper'

RSpec.describe 'api/v3/assets/index.json.jbuilder', type: :view do
  let(:asset) { create(:asset) }

  it 'renders asset' do
    assign(:assets, [asset])
    render
    expect(JSON.parse(rendered)).to eq(
      'assets' => [{
        'id' => asset.id,
        'uuid' => asset.uuid,
        'type' => asset.type,
        'image' => asset.vector.url,
        'raster' => asset.raster.url,
        'vector' => asset.vector.url,
        'colorizable' => asset.colorizable
      }]
    )
  end
end
