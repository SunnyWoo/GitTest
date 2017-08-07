require 'spec_helper'

RSpec.describe 'api/v3/_wishlist.json.jbuilder', :caching, type: :view do
  let(:product) { create(:product_model) }
  let(:work) { create(:work, product: product) }
  let!(:previews) { create_list(:preview, 2, work: work) }
  let(:wishlist) { create(:wishlist) }

  it 'renders wishlist' do
    work.reload
    wishlist.works << work
    render 'api/v3/wishlist', wishlist: wishlist
    expect(JSON.parse(rendered)).to eq(
      'id' => wishlist.id,
      'user_id' => wishlist.user_id,
      'user_type' => wishlist.user.role,
      'works' => [{
        'id' => work.id,
        'gid' => work.to_gid_param,
        'uuid' => work.uuid,
        'name' => work.name,
        'user_avatar' => work.user_avatar.as_json.deep_stringify_keys,
        'user_id' => work.user_id,
        'order_image' => {
          'thumb' => work.order_image.thumb.url,
          'share' => work.order_image.share.url,
          'sample' => work.order_image.sample.url,
          'normal' => work.order_image.url
        },
        'gallery_images' => work.ordered_previews.map do |preview|
          {
            'normal' => preview.image.url,
            'thumb' => preview.image.thumb.url,
            'key' => preview.key,
            'url' => preview.image.url
          }
        end,
        'prices' => work.prices,
        'original_prices' => work.original_prices,
        'user_display_name' => work.user_display_name,
        'wishlist_included' => false,
        'slug' => work.slug,
        'is_public' => work.is_public?,
        'user_avatars' => {
          's35' => work.user.avatar.s35.url,
          's154' => work.user.avatar.s154.url
        },
        'spec' => {
          'id' => work.product.id,
          'name' => work.product.name,
          'description' => work.product.description,
          'width' => work.product.width,
          'height' => work.product.height,
          'dpi' => work.product.dpi,
          'background_image' => work.product.background_image.url,
          'overlay_image' => work.product.overlay_image.url,
          'padding_top' => work.product.padding_top.to_s,
          'padding_right' => work.product.padding_right.to_s,
          'padding_bottom' => work.product.padding_bottom.to_s,
          'padding_left' => work.product.padding_left.to_s,
          '__deprecated' => 'WorkSpec is not longer available'
        },
        'model' => {
          'id' => work.product.id,
          'key' => work.product.key,
          'name' => work.product.name,
          'description' => work.product.description,
          'prices' => work.product.prices,
          'customized_special_prices' => work.product.customized_special_prices,
          'design_platform' => work.product.design_platform,
          'customize_platform' => work.product.customize_platform,
          'placeholder_image' => work.product.placeholder_image.url,
          'width' => work.product.width,
          'height' => work.product.height,
          'dpi' => work.product.dpi,
          'background_image' => work.product.background_image.url,
          'overlay_image' => work.product.overlay_image.url,
          'padding_top' => work.product.padding_top.to_s,
          'padding_right' => work.product.padding_right.to_s,
          'padding_bottom' => work.product.padding_bottom.to_s,
          'padding_left' => work.product.padding_left.to_s
        },
        'product' => {
          'id' => work.product.id,
          'key' => work.product.key,
          'name' => work.product.name,
          'description' => work.product.description,
          'prices' => work.product.prices,
          'customized_special_prices' => work.product.customized_special_prices,
          'design_platform' => work.product.design_platform,
          'customize_platform' => work.product.customize_platform,
          'placeholder_image' => work.product.placeholder_image.url,
          'width' => work.product.width,
          'height' => work.product.height,
          'dpi' => work.product.dpi,
          'background_image' => work.product.background_image.url,
          'overlay_image' => work.product.overlay_image.url,
          'padding_top' => work.product.padding_top.to_s,
          'padding_right' => work.product.padding_right.to_s,
          'padding_bottom' => work.product.padding_bottom.to_s,
          'padding_left' => work.product.padding_left.to_s
        },
        'category' => {
          'id' => work.category.id,
          'key' => work.category.key,
          'name' => work.category.name
        },
        'featured' => work.featured?,
        'tags' => work.tags.each do |tag|
          {
            'id' => tag.id,
            'name' => tag.name
          }
        end
      }]
    )
  end
end
