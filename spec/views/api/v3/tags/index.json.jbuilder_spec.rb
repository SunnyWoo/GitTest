require 'spec_helper'

RSpec.describe 'api/v3/tags/index.json.jbuilder', :caching, type: :view do
  let(:tag) { create(:tag) }

  it 'renders tag' do
    assign(:tags, [tag])
    render
    expect(JSON.parse(rendered)).to eq(
      'tags' => [{
        'id' => tag.id,
        'name' => tag.name,
        'text' => tag.text
      }]
    )
  end
end
