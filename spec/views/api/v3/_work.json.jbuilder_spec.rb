require 'spec_helper'

RSpec.describe 'api/v3/_work.json.jbuilder', :caching, type: :view do
  let(:product) { create(:product_model) }
  let(:work) { create(:work, product: product) }
  let!(:previews) { create_list(:preview, 2, work: work) }

  it 'renders work' do
    work.reload
    render 'api/v3/work', work: work
    expect(JSON.parse(rendered)).to eq(
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
          'id' => preview.id,
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
          'name' => tag.name,
          'text' => tag.text
        }
      end
    )
  end

  it 'renders work with given user' do
    user = create(:user)
    user.create_wishlist.works << work
    render 'api/v3/work', work: work, scope: user
    expect(JSON.parse(rendered)).to eq(
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
          'id' => preview.id,
          'normal' => preview.image.url,
          'thumb' => preview.image.thumb.url,
          'key' => preview.key,
          'url' => preview.image.url
        }
      end,
      'prices' => work.prices,
      'original_prices' => work.original_prices,
      'user_display_name' => work.user_display_name,
      'wishlist_included' => true,
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
          'name' => tag.name,
          'text' => tag.text
        }
      end
    )
  end

  context 'when work is a standardized work' do
    let(:work) { create(:standardized_work, :with_order_image) }

    it 'renders work with given user' do
      render 'api/v3/work', work: work
      expect(JSON.parse(rendered)).to eq(
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
            'id' => preview.id,
            'normal' => preview.image.url,
            'thumb' => preview.image.thumb.url,
            'key' => preview.key,
            'url' => preview.image.url,
            'image_url' => preview.image.url,
            'position' => preview.position
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
            'name' => tag.name,
            'text' => tag.text
          }
        end
      )
    end
  end

  context 'when work is a standardized work without order image' do
    let(:work) { create(:standardized_work) }

    it 'renders work with given user' do
      render 'api/v3/work', work: work
      expect(JSON.parse(rendered)).to eq(
        'id' => work.id,
        'gid' => work.to_gid_param,
        'uuid' => work.uuid,
        'name' => work.name,
        'user_avatar' => work.user_avatar.as_json.deep_stringify_keys,
        'user_id' => work.user_id,
        'order_image' => {
          'thumb' => nil,
          'share' => nil,
          'sample' => nil,
          'normal' => nil
        },
        'gallery_images' => work.ordered_previews.map do |preview|
          {
            'id' => preview.id,
            'normal' => preview.image.url,
            'thumb' => preview.image.thumb.url,
            'key' => preview.key,
            'url' => preview.image.url,
            'image_url' => preview.image.url,
            'position' => preview.position
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
            'name' => tag.name,
            'text' => tag.text
          }
        end
      )
    end
  end

  it 'renders work with include_layers' do
    work.reload
    layer = create(:layer)
    work.layers = [layer]
    render 'api/v3/work', work: work, include_layers: true
    expect(JSON.parse(rendered)).to eq(
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
          'name' => tag.name,
          'text' => tag.text
        }
      end,
      'layers' => work.layers.map do |layer|
        {
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
        }
      end
    )
  end
end
