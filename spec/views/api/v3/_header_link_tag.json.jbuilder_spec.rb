require 'spec_helper'

RSpec.describe 'api/v3/_header_link_tag.json.jbuilder', :caching, type: :view do
  let(:tag) do
    create(:header_link_tag)
  end

  it 'renders header link tag' do
    render 'api/v3/header_link_tag', tag: tag
    expect(JSON.parse(rendered)).to eq(
      'title' => tag.title,
      'style' => tag.style
    )
  end
end
