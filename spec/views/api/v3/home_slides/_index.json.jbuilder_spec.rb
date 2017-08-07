require 'spec_helper'

RSpec.describe 'api/v3/home_slides/index.json.jbuilder', type: :view do
  let(:home_slide) { create(:home_slide) }

  it 'renders home_slide' do
    assign(:home_slides, [home_slide])
    render
    expect(JSON.parse(rendered)).to eq(
      'home_slides' => [{
        'id' => home_slide.id,
        'set' => home_slide.set,
        'template' => home_slide.template,
        'background' => home_slide.background.s1600.url,
        'slide' => home_slide.slide.url,
        'title' => home_slide.title,
        'link' => home_slide.link,
        'desc' => home_slide.desc,
        'priority' => home_slide.priority
      }]
    )
  end
end
