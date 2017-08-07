require 'spec_helper'

RSpec.describe 'api/v3/_tag.json.jbuilder', :caching, type: :view do
  let(:tag) { create(:tag) }

  it 'renders tag' do
    render 'api/v3/tag', tag: tag
    expect(JSON.parse(rendered)).to eq(
      'id' => tag.id,
      'name' => tag.name,
      'text' => tag.text
    )
  end
end
