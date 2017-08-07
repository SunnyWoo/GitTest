require 'spec_helper'

RSpec.describe 'api/v3/tags/show.json.jbuilder', :caching, type: :view do
  let(:tag) { create(:tag) }

  it 'renders tag' do
    assign(:tag, tag)
    render
    expect(JSON.parse(rendered)).to eq(
      'tag' => {
        'id' => tag.id,
        'name' => tag.name,
        'text' => tag.text
      }
    )
  end
end
