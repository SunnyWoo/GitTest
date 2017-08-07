require 'spec_helper'

RSpec.describe 'api/v3/designers/index.json.jbuilder', type: :view do
  let(:designer) { create(:designer) }

  it 'renders designer' do
    assign(:designers, [designer])
    render
    expect(JSON.parse(rendered)).to eq(
      'designers' => [{
        'id' => designer.id,
        'display_name' => designer.display_name
      }]
    )
  end
end
