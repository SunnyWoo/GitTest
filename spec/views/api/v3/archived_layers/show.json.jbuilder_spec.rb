require 'spec_helper'

RSpec.describe 'api/v3/archived_layers/show.json.jbuilder', type: :view do
  let(:layer) do
    create(:archived_layer)
  end

  it 'renders layer' do
    assign(:layer, layer)
    render
    expect(JSON.parse(rendered)).to eq(
      'layer' => {
        'id' => layer.id,
        'layer_type' => layer.layer_type,
        'position_x' => layer.position_x,
        'position_y' => layer.position_y,
        'orientation' => layer.orientation,
        'scale_x' => layer.scale_x,
        'scale_y' => layer.scale_y,
        'transparent' => layer.transparent,
        'color' => layer.color,
        'material_name' => layer.material_name,
        'font_name' => layer.font_name,
        'font_text' => layer.font_text,
        'text_alignment' => layer.text_alignment,
        'text_spacing_x' => layer.text_spacing_x,
        'text_spacing_y' => layer.text_spacing_y,
        'image' => {
          'normal' => layer.image.url,
          'md5sum' => layer.image.md5sum
        },
        'filter' => layer.filter,
        'filtered_image' => {
          'normal' => layer.filtered_image.url,
          'md5sum' => layer.filtered_image.md5sum
        },
        'position' => layer.position,
        'masked' => layer.mask.present?,
        'masked_layers' => layer.masked_layers.map do |masked_layer|
          {
            'id' => masked_layer.id,
            'uuid' => masked_layer.id
          }
        end,
        'disabled' => layer.disabled?
      }
    )
  end
end
