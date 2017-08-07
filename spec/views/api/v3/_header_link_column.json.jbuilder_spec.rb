require 'spec_helper'

RSpec.describe 'api/v3/_header_link_column.json.jbuilder', :caching, type: :view do
  let(:link) { create(:header_link, href: '', blank: true, link_type: :text, dropdown: true, tags: [tag]) }
  let(:tag) { create(:header_link_tag) }

  it 'renders header link column' do
    render 'api/v3/header_link_column', link: link
    expect(JSON.parse(rendered)).to eq(
      'title' => link.title,
      'href' => link.href,
      'blank' => link.blank,
      'link_type' => link.link_type.to_s,
      'spec_id' => link.spec_id,
      'auto_generate_product' => link.auto_generate_product,
      'tags' => [tag].map do |tag|
        {
          'title' => tag.title,
          'style' => tag.style
        }
      end
    )
  end
end
