require 'spec_helper'

RSpec.describe 'api/v3/_home_block_item.json.jbuilder', :caching, type: :view do
  let(:item) { create(:home_block_item) }

  it 'renders home block item' do
    render 'api/v3/home_block_item', item: item
    expect(JSON.parse(rendered)).to eq(
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
    )
  end
end
