require 'spec_helper'

RSpec.describe 'api/v3/home_blocks/show.json.jbuilder', type: :view do
  let(:block) { create(:home_block) }
  let!(:item) { create(:home_block_item, block: block) }

  it 'renders home block' do
    assign(:home_block, block)
    render
    expect(JSON.parse(rendered)).to eq(
      'home_block' => {
        'id' => block.id,
        'title' => block.title,
        'template' => block.template,
        'position' => block.position,
        'title_translations' => view.full_translations(block.title_translations),
        'items' => [{
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
      }
    )
  end
end
