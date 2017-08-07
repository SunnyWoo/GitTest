require 'spec_helper'

RSpec.describe 'api/v3/_masked_layer.json.jbuilder', :caching, type: :view do
  let(:layer) do
    create(:layer)
  end

  it 'renders layer' do
    render 'api/v3/masked_layer', layer: layer
    expect(JSON.parse(rendered)).to eq(
      'id' => layer.id,
      'uuid' => layer.uuid
    )
  end
end
