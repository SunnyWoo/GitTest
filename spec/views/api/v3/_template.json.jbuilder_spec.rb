require 'spec_helper'

RSpec.describe 'api/v3/_template.json.jbuilder', :caching, type: :view do
  let(:template) { create(:work_template) }

  it 'renders template' do
    render 'api/v3/template', template: template
    expect(JSON.parse(rendered)).to eq(
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
    )
  end
end
