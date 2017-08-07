require 'spec_helper'

RSpec.describe 'api/v3/templates/index.json.jbuilder', :caching, type: :view do
  let(:template) { create(:work_template) }

  it 'renders template' do
    assign(:templates, [template])
    render
    expect(JSON.parse(rendered)).to eq(
      'templates' => [{
        'id' => template.id,
        'background_image' => {
          'w320' => template.background_image.w320.url,
          'w640' => template.background_image.w640.url
        },
        'overlay_image' => {
          'w320' => template.overlay_image.w320.url,
          'w640' => template.overlay_image.w640.url
        },
        'masks' => template.masks
      }],
      'meta' => {
        'templates_count' => 1
      }
    )
  end
end
