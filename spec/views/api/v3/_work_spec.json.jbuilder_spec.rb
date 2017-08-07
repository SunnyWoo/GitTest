require 'spec_helper'

RSpec.describe 'api/v3/_work_spec.json.jbuilder', :caching, type: :view do
  let(:spec) do
    create(:work_spec)
  end

  it 'renders work spec' do
    render 'api/v3/work_spec', spec: spec
    expect(JSON.parse(rendered)).to eq(
      'id' => spec.id,
      'name' => spec.name,
      'description' => spec.description,
      'width' => spec.width,
      'height' => spec.height,
      'dpi' => spec.dpi,
      'background_image' => spec.background_image.url,
      'overlay_image' => spec.overlay_image.url,
      'padding_top' => spec.padding_top.to_s,
      'padding_right' => spec.padding_right.to_s,
      'padding_bottom' => spec.padding_bottom.to_s,
      'padding_left' => spec.padding_left.to_s,
      '__deprecated' => 'WorkSpec is not longer available'
    )
  end
end
