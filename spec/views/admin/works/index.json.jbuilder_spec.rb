require 'spec_helper'

RSpec.describe 'admin/works/index.json.jbuilder', :caching, type: :view do
  let(:work) { create(:work) }

  it 'renders work' do
    assign(:works, [work])
    render
    expect(JSON.parse(rendered)).to eq(
      'works' => [{
        'id' => work.id,
        'name' => work.name,
        'description' => work.description,
        'remote_cover_image_url' => work.cover_image.url,
        'model' => work.product.name,
        'remote_print_image_url' => work.print_image.url,
        'remote_order_image_url' => work.order_image.url,
        'user_display_name' => work.user_display_name,
        'gid' => work.to_gid_param
      }],
      'meta' => {
        'query' => nil,
        'page' => nil
      }
    )
  end
end
