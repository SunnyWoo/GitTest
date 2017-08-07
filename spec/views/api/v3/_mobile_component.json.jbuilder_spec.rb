require 'spec_helper'

RSpec.describe 'api/v3/_mobile_component.json.jbuilder', :caching, type: :view do
  context 'when component is a kv' do
    let(:mobile_component) { create(:kv_mobile_component) }

    it 'renders kv' do
      render 'api/v3/mobile_component', component: mobile_component
      expect(JSON.parse(rendered)).to eq(
        'key' => mobile_component.key,
        'position' => mobile_component.position,
        'items' => mobile_component.sub_components.map do |sub|
          {
            'image' => {
              'thumb' => sub.image.thumb.url,
              'normal' => sub.image.url,
              'large' => sub.image.url
            },
            'action_type' => sub.contents.action_type,
            'action_target' => sub.contents.action_target,
            'action_key' => sub.contents.action_key
          }
        end
      )
    end
  end

  context 'when component is a ticker' do
    let(:mobile_component) { create(:ticker_mobile_component) }

    it 'renders ticker' do
      render 'api/v3/mobile_component', component: mobile_component
      expect(JSON.parse(rendered)).to eq(
        'key' => mobile_component.key,
        'position' => mobile_component.position,
        'title' => mobile_component.contents.title,
        'contents' => mobile_component.sub_components.map { |sub| sub.contents.content }
      )
    end
  end

  context 'when component is a product line' do
    let(:mobile_component) { create(:product_line_mobile_component) }

    it 'renders product line' do
      render 'api/v3/mobile_component', component: mobile_component
      expect(JSON.parse(rendered)).to eq(
        'key' => mobile_component.key,
        'position' => mobile_component.position,
        'products' => mobile_component.sub_components.map { |sub| sub.contents.content }
      )
    end
  end

  context 'when component is a redeem' do
    let(:mobile_component) { create(:redeem_mobile_component) }

    it 'renders redeem' do
      render 'api/v3/mobile_component', component: mobile_component
      expect(JSON.parse(rendered)).to eq(
        'key' => mobile_component.key,
        'position' => mobile_component.position
      )
    end
  end

  context 'when component is a campaign section' do
    let(:mobile_component) { create(:campaign_section_mobile_component) }

    it 'renders campaign section' do
      render 'api/v3/mobile_component', component: mobile_component
      expect(JSON.parse(rendered)).to eq(
        'key' => mobile_component.key,
        'position' => mobile_component.position,
        'section_title' => mobile_component.contents.section_title,
        'section_color' => mobile_component.contents.section_color,
        'campaigns' => mobile_component.sub_components.map do |sub|
          campaign = sub.campaign
          {
            'image' => {
              'thumb' => sub.image.thumb.url,
              'normal' => sub.image.url,
              'large' => sub.image.url
            },
            'page_type' => campaign.page_type,
            'title' => sub.contents.title,
            'description' => sub.contents.desc_short,
            'action_text' => sub.contents.action_text,
            'key' => campaign.key,
            'begin_at' => campaign.begin_at.as_json,
            'close_at' => campaign.close_at.as_json,
            'limited_count' => 0
          }
        end
      )
    end
  end

  context 'when component is a products section' do
    def work_json(work)
      order_image = Monads::Optional.new(work.order_image)
      {
        'id' => work.id,
        'gid' => work.to_gid_param,
        'uuid' => work.uuid,
        'name' => work.name,
        'user_avatar' => work.user_avatar.as_json.deep_stringify_keys,
        'user_id' => work.user_id,
        'order_image' => {
          'thumb' => order_image.thumb.url.value,
          'share' => order_image.share.url.value,
          'sample' => order_image.sample.url.value,
          'normal' => order_image.url.value
        },
        'gallery_images' => work.ordered_previews.map do |preview|
          {
            'normal' => preview.image.url,
            'thumb' => preview.image.thumb.url
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
      }
    end

    context 'and component does not have designer_id' do
      let(:mobile_component) { create(:products_section_mobile_component) }

      it 'renders products section' do
        render 'api/v3/mobile_component', component: mobile_component
        expect(JSON.parse(rendered)).to eq(
          'key' => mobile_component.key,
          'position' => mobile_component.position,
          'section_title' => mobile_component.contents.section_title,
          'section_color' => mobile_component.contents.section_color,
          'product_type' => mobile_component.contents.product_type,
          'background' => {
            'thumb' => mobile_component.image.thumb.url,
            'normal' => mobile_component.image.url,
            'large' => mobile_component.image.url
          },
          'products' => mobile_component.sub_components.map do |sub|
            work = sub.work
            {
              'image' => {
                'thumb' => sub.image.thumb.url,
                'normal' => sub.image.url,
                'large' => sub.image.url
              },
              'gid' => work.to_gid_param,
              'uuid' => work.uuid,
              'title' => sub.contents.title,
              'description' => sub.contents.desc_short,
              'original_price' => work.product.prices,
              'price' => work.prices,
              'tip_text' => sub.contents.tip_text.to_s,
              'will_sale_text' => sub.contents.will_sale_text,
              'on_sale_text' => sub.contents.on_sale_text,
              'action_type' => sub.contents.action_type,
              'action_target' => sub.contents.action_target,
              'action_key' => sub.contents.action_key
            }.merge(work_json(work))
          end
        )
      end
    end

    context 'and component have designer_id' do
      let(:mobile_component) { create(:products_section_with_designer_mobile_component) }
      let!(:standardized_work) { create(:standardized_work, :published, user: mobile_component.designer) }

      it 'renders products section' do
        render 'api/v3/mobile_component', component: mobile_component
        expect(JSON.parse(rendered)).to eq(
          'key' => mobile_component.key,
          'position' => mobile_component.position,
          'section_title' => mobile_component.contents.section_title,
          'section_color' => mobile_component.contents.section_color,
          'product_type' => mobile_component.contents.product_type,
          'background' => {
            'thumb' => mobile_component.image.thumb.url,
            'normal' => mobile_component.image.url,
            'large' => mobile_component.image.url
          },
          'products' => mobile_component.designer.standardized_works.is_public.with_available_product.map do |work|
            order_image = Monads::Optional.new(work.order_image)
            {
              'image' => {
                'thumb' => order_image.thumb.url.value,
                'normal' => order_image.url.value,
                'large' => order_image.url.value
              },
              'gid' => work.to_gid_param,
              'uuid' => work.uuid,
              'title' => work.name,
              'description' => work.product_name,
              'original_price' => work.product.prices,
              'price' => work.prices,
              'tip_text' => mobile_component.contents_tip_text,
              'will_sale_text' => mobile_component.contents_will_sale_text,
              'on_sale_text' => mobile_component.contents_on_sale_text,
              'action_type' => 'shop',
              'action_target' => nil,
              'action_key' => work.uuid
            }.merge(work_json(work))
          end
        )
      end
    end
  end

  context 'when component is a tab section' do
    let(:mobile_component) { create(:tab_section_mobile_component) }

    it 'renders tab section' do
      render 'api/v3/mobile_component', component: mobile_component
      expect(JSON.parse(rendered)).to eq(
        'key' => mobile_component.key,
        'position' => mobile_component.position,
        'create_text' => mobile_component.sub_components.first.contents.create_text,
        'shop_text' => mobile_component.sub_components.first.contents.shop_text,
        'download_text' => mobile_component.sub_components.first.contents.download_text
      )
    end
  end

  context 'when component is a media section' do
    let(:mobile_component) { create(:media_section_mobile_component) }

    it 'renders media section' do
      render 'api/v3/mobile_component', component: mobile_component
      expect(JSON.parse(rendered)).to eq(
        'key' => mobile_component.key,
        'position' => mobile_component.position,
        'items' => mobile_component.sub_components.map do |sub|
          {
            'image' => {
              'thumb' => sub.image.thumb.url,
              'normal' => sub.image.url,
              'large' => sub.image.url
            },
            'title' => sub.contents.title,
            'content' => sub.contents.content,
            'media_type' => sub.contents.media_type,
            'tab_category' => sub.contents.tab_category,
            'media_url' => sub.contents.media_url,
            'action_text' => sub.contents.action_text,
            'action_type' => sub.contents.action_type,
            'action_target' => sub.contents.action_target,
            'action_key' => sub.contents.action_key
          }
        end
      )
    end
  end

  context 'when component is a create section' do
    let(:mobile_component) { create(:create_section_mobile_component) }

    it 'renders create section' do
      render 'api/v3/mobile_component', component: mobile_component
      expect(JSON.parse(rendered)).to eq(
        'key' => mobile_component.key,
        'position' => mobile_component.position,
        'title' => mobile_component.contents.title,
        'background' => {
          'thumb' => mobile_component.image.thumb.url,
          'normal' => mobile_component.image.url,
          'large' => mobile_component.image.url
        },
        'items' => mobile_component.sub_components.map do |sub|
          {
            'image' => {
              'thumb' => sub.image.thumb.url,
              'normal' => sub.image.url,
              'large' => sub.image.url
            },
            'title' => sub.contents.title,
            'action_type' => 'create',
            'action_target' => '',
            'action_key' => ''
          }
        end
      )
    end
  end

  context 'when component is a description section' do
    let(:mobile_component) { create(:description_section_mobile_component) }

    it 'renders description section' do
      render 'api/v3/mobile_component', component: mobile_component
      expect(JSON.parse(rendered)).to eq(
        'key' => mobile_component.key,
        'position' => mobile_component.position,
        'items' => mobile_component.sub_components.map do |sub|
          {
            'title' => sub.contents.title,
            'description' => sub.contents.description
          }
        end
      )
    end
  end

  context 'when component is a download section' do
    let(:mobile_component) { create(:download_section_mobile_component) }

    it 'renders download section' do
      render 'api/v3/mobile_component', component: mobile_component
      expect(JSON.parse(rendered)).to eq(
        'key' => mobile_component.key,
        'position' => mobile_component.position,
        'title' => mobile_component.contents.title,
        'background' => {
          'thumb' => mobile_component.image.thumb.url,
          'normal' => mobile_component.image.url,
          'large' => mobile_component.image.url
        },
        'items' => mobile_component.sub_components.map do |sub|
          {
            'image' => {
              'thumb' => sub.image.thumb.url,
              'normal' => sub.image.url,
              'large' => sub.image.url
            },
            'title' => sub.contents.title,
            'download_url' => sub.contents.download_url,
            'action_type' => 'create',
            'action_target' => '',
            'action_key' => ''
          }
        end
      )
    end
  end

  # context 'when component is a ticker' do
  #   let(:mobile_component) { create(:ticker_mobile_component) }

  #   it 'renders mobile component' do
  #     render 'api/v3/mobile_component', component: mobile_component
  #     expect(JSON.parse(rendered)).to eq(
  #       'key' => mobile_component.key,
  #       'position' => mobile_component.position
  #     )
  #   end
  # end
end
