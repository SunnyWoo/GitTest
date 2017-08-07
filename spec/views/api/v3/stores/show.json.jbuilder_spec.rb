require 'spec_helper'

RSpec.describe 'api/v3/stores/show.json.jbuilder', :caching, type: :view do
  let(:store) { build_stubbed(:store) }

  it 'renders store' do
    assign(:store, store)
    render
    expect(JSON.parse(rendered)).to eq(
      'store' => {
        'id' => store.id,
        'slug' => store.slug,
        'avatar' => store.avatar.url,
        'title' => store.title,
        'description' => store.description
      }
    )
  end
end
