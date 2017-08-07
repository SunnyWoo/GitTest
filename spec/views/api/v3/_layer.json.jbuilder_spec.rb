require 'spec_helper'

RSpec.describe 'api/v3/_layer.json.jbuilder', :caching, type: :view do
  shared_examples 'renders layer successfully' do
    it 'renders layer' do
      render 'api/v3/layer', layer: layer
      expect(JSON.parse(rendered)).to eq(
        'id' => layer.id,
        'uuid' => layer.uuid,
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
        end
      )
    end
  end

  context 'when layer is a normal layer' do
    let(:layer) do
      create(:layer)
    end
    include_examples 'renders layer successfully'
  end

  context 'when layer is a mask' do
    let(:layer) do
      create(:layer, layer_type: :mask)
    end
    include_examples 'renders layer successfully'
  end

  context 'when layer is masked' do
    let(:layer) do
      create(:layer, mask: create(:layer, layer_type: :mask))
    end
    include_examples 'renders layer successfully'
  end
end
