require 'spec_helper'

RSpec.describe 'api/v1/layers/show.json.jbuilder', :caching, type: :view do
  let(:layer) { create(:layer) }

  it 'renders layer' do
    assign(:layer, layer)
    render
    expect(JSON.parse(rendered)).to eq(
      'id' => layer.id,
      'uuid' => layer.uuid,
      # 'layer_type' => layer.layer_type, # overrided
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
      'layer_type' => layer.layer_type_key,
      'name' => layer.material_name,
      'work_id' => layer.work.id,
      'work_uuid' => layer.work.uuid,
      'image_url' => layer.image.url
    )
  end

  it 'includes LayerSerializer' do
    assign(:layer, layer)
    render
    expect(JSON.parse(rendered)).to include(
      'uuid' => layer.uuid,
      'position_x' => layer.position_x,
      'position_y' => layer.position_y,
      'orientation' => layer.orientation,
      'scale_x' => layer.scale_x,
      'scale_y' => layer.scale_y,
      'color' => layer.color,
      'font_name' => layer.font_name,
      'font_text' => layer.font_text,
      'image_url' => layer.image.url,
      'name' => layer.material_name,
      'work_id' => layer.work.id,
      'work_uuid' => layer.work.uuid,
      'layer_type' => layer.layer_type_key,
      'filter' => layer.filter,
      'text_spacing_x' => layer.text_spacing_x,
      'text_spacing_y' => layer.text_spacing_y,
      'position' => layer.position,
      'text_alignment' => layer.text_alignment,
      'transparent' => layer.transparent,
      'material_name' => layer.material_name
    )
  end
end
