require 'spec_helper'

RSpec.describe 'api/v3/header_links/index.json.jbuilder', type: :view do
  let(:parent_link) { create(:header_link, href: '', blank: true, dropdown: true, children: [child_link]) }
  let(:child_link) { create(:header_link, link_type: :text, row: 1) }

  it 'renders header link' do
    assign(:header_links, [parent_link])
    render
    expect(JSON.parse(rendered)).to eq(
      'header_links' => [{
        'title' => parent_link.title,
        'href' => parent_link.href,
        'blank' => parent_link.blank,
        'dropdown' => parent_link.dropdown,
        'auto_generate_product' => parent_link.auto_generate_product,
        'columns' => [
          'links' => [{
            'title' => child_link.title,
            'href' => child_link.href,
            'blank' => child_link.blank,
            'link_type' => child_link.link_type.to_s,
            'spec_id' => child_link.spec_id,
            'auto_generate_product' => child_link.auto_generate_product,
            'tags' => child_link.tags.map do |tag|
              {
                'title' => tag.title,
                'style' => tag.style
              }
            end
          }]
        ]
      }]
    )
  end
end
