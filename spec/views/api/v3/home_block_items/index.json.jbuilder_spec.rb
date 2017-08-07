require 'spec_helper'

RSpec.describe 'api/v3/home_block_items/index.json.jbuilder', :caching, type: :view do
  let(:item) { create(:home_block_item) }

  it 'renders home block item' do
    assign(:block_items, [item])
    render
    expect(JSON.parse(rendered)).to eq(
      'block_items' => [{
        'id' => item.id,
        'block_id' => item.block_id,
        'title' => item.title,
        'title_translations' => view.full_translations(item.title_translations),
        'subtitle' => item.subtitle,
        'subtitle_translations' => view.full_translations(item.subtitle_translations),
        'href' => item.href,
        'image' => item.pic.try(:thumb).try(:url),
        'position' => item.position,
        'pic_translations' => view.full_translations(
          item.translations.each_with_object({}) do |t, hash|
            hash[t.locale.to_s] = t.pic.thumb.url
          end
        )
      }]
    )
  end
end
