require 'spec_helper'

RSpec.describe Product::ExportService do
  Given(:product) { create(:product_model) }
  Given(:layers) do
    {
      background_width: '640',
      background_height: '320',
      mask_left: '70',
      mask_top: '30',
      mask_width: '500',
      mask_height: '200'
    }
  end
  Given(:composer) { PreviewComposer::FrontBack.new }
  Given do
    composer.background
    composer.case
    composer.update(background_width: 640,
                    background_height: 480,
                    case_file: file,
                    product: product)
  end
  Given(:export) { Product::ExportService.new([product.id]) }

  context '#init' do
    Then { export.ids == [product.id] }
  end

  context '#execute' do
    Given(:export_json) { JSON.parse(export.execute)[0] }
    Then { export_json['product_key'] == product.key }
    And do
      export_json['category'] == {
        'key' => product.category.key,
        'name_zh_tw' => product.category.name_zh_tw,
        'name_zh_cn' => product.category.name_zh_cn,
        'name_en' => product.category.name_en,
        'name_ja' => product.category.name_ja,
        'name_zh_hk' => product.category.name_zh_hk
      }
    end

    Given(:attributes) { export_json['attributes'] }
    And { attributes['slug'] == product.slug }
    And { attributes['key'] == product.key }
    And { attributes['dir_name'] == product.dir_name }
    And { attributes['material'] == product.material }
    And { attributes['weight'] == product.weight }
    And { attributes['enable_white'] == product.enable_white }
    And { attributes['auto_imposite'] == product.auto_imposite }
    And { attributes['name_zh_tw'] == product.name_zh_tw }
    And { attributes['description_zh_tw'] == product.description_zh_tw }
    And { attributes['short_name_zh_tw'] == product.short_name_zh_tw }
    And { attributes['name_zh_cn'] == product.name_zh_cn }
    And { attributes['description_zh_cn'] == product.description_zh_cn }
    And { attributes['short_name_zh_cn'] == product.short_name_zh_cn }
    And { attributes['name_en'] == product.name_en }
    And { attributes['description_en'] == product.description_en }
    And { attributes['short_name_en'] == product.short_name_en }
    And { attributes['name_ja'] == product.name_ja }
    And { attributes['description_ja'] == product.description_ja }
    And { attributes['short_name_ja'] == product.short_name_ja }
    And { attributes['name_zh_hk'] == product.name_zh_hk }
    And { attributes['description_zh_hk'] == product.description_zh_hk }
    And { attributes['short_name_zh_hk'] == product.short_name_zh_hk }
    And { attributes['aasm_state'] == product.aasm_state }
    And { attributes['code'] == product.code }
    And { attributes['external_code'] == product.external_code }
    And { attributes['width'] == product.width }
    And { attributes['height'] == product.height }
    And { attributes['dpi'] == product.dpi }
    And { attributes['shape'] == product.shape }
    And { attributes['alignment_points'] == product.alignment_points }
    And { attributes['background_color'] == product.background_color }
    And { attributes['padding_top'] == product.padding_top.to_s }
    And { attributes['padding_right'] == product.padding_right.to_s }
    And { attributes['padding_bottom'] == product.padding_bottom.to_s }
    And { attributes['padding_left'] == product.padding_left.to_s }
    And { attributes['enable_composite_with_horizontal_rotation'] == product.enable_composite_with_horizontal_rotation }
    And { attributes['create_order_image_by_cover_image'] == product.create_order_image_by_cover_image }
    And { attributes['remote_placeholder_image_url'] == product.placeholder_image.url }
    And { attributes['remote_print_image_mask_url'] == product.print_image_mask.url }
    And { attributes['remote_watermark_url'] == product.watermark.url }
    And { attributes['remote_background_image_url'] == product.background_image.url }
    And { attributes['remote_overlay_image_url'] == product.overlay_image.url }

    Given(:preview_composers) { export_json['preview_composers'][0] }
    Then {
      preview_composers == {
        'key' => composer.key,
        'type' => composer.type,
        'available' => composer.available,
        'position' => composer.position,
        'background_width' => composer.background_width,
        'background_height' => composer.background_height,
        'case_file' => composer.case.uploader.url
      }
    }
  end

  def file
    tempfile = File.new(Rails.root + 'spec/fixtures/great-design.jpg')
    ActionDispatch::Http::UploadedFile.new(filename: 'case.jpg',
                                           type: 'image/jpeg',
                                           tempfile: tempfile)
  end
end
