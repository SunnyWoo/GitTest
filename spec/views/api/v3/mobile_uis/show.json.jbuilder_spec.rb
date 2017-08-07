require 'spec_helper'

RSpec.describe 'api/v3/mobile_uis/show.json.jbuilder', type: :view do
  let(:mobile_ui) { create(:mobile_ui) }

  it 'renders mobile_ui' do
    assign(:mobile_ui, mobile_ui)
    render
    expect(JSON.parse(rendered)).to eq(
      'mobile_ui' => {
        'title' => mobile_ui.title,
        'template' => mobile_ui.template,
        'links' => {
          '1x' => mobile_ui.image.x_1.url,
          '2x' => mobile_ui.image.x_2.url,
          '3x' => mobile_ui.image.url
        }
      }
    )
  end
end
