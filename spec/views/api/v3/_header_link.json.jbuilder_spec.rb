require 'spec_helper'

RSpec.describe 'api/v3/_header_link.json.jbuilder', :caching, type: :view do
  let(:parent_link) do
    create(:header_link, href: '', blank: true, dropdown: true, children: [child_link_1, child_link_2])
  end
  let(:child_link_1) { create(:header_link, link_type: :text, row: 1) }
  let(:child_link_2) { create(:header_link, link_type: :text, row: 2) }

  it 'renders header link' do
    render 'api/v3/header_link', link: parent_link
    expect(JSON.parse(rendered)).to eq(
      'title' => parent_link.title,
      'href' => parent_link.href,
      'blank' => parent_link.blank,
      'dropdown' => parent_link.dropdown,
      'auto_generate_product' => parent_link.auto_generate_product,
      'columns' => [
        {
          'links' => [{
            'title' => child_link_1.title,
            'href' => child_link_1.href,
            'blank' => child_link_1.blank,
            'link_type' => child_link_1.link_type.to_s,
            'spec_id' => child_link_1.spec_id,
            'auto_generate_product' => child_link_1.auto_generate_product,
            'tags' => child_link_1.tags.map do |tag|
              {
                'title' => tag.title,
                'style' => tag.style
              }
            end
          }]
        },
        {
          'links' => [{
            'title' => child_link_2.title,
            'href' => child_link_2.href,
            'blank' => child_link_2.blank,
            'link_type' => child_link_2.link_type.to_s,
            'spec_id' => child_link_2.spec_id,
            'auto_generate_product' => child_link_2.auto_generate_product,
            'tags' => child_link_2.tags.map do |tag|
              {
                'title' => tag.title,
                'style' => tag.style
              }
            end
          }]
        }

      ]
    )
  end
end
