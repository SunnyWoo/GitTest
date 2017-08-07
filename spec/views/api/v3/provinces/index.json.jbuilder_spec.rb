require 'spec_helper'

RSpec.describe 'api/v3/provinces/index.json.jbuilder', type: :view do
  let(:province) { create(:province) }

  it 'renders province' do
    assign(:provinces, [province])
    render
    expect(JSON.parse(rendered)).to eq(
      'provinces' => [{
        'id' => province.id,
        'name' => province.name
      }]
    )
  end
end
