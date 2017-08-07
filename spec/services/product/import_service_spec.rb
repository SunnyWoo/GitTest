require 'spec_helper'

RSpec.describe Product::ImportService do
  Given { create(:factory) }
  Given(:json) { "[{\"product_key\":\"iphone_2_case\",\"category\":{\"key\":\"product_category_2\",\"name_zh_tw\":null,\"name_zh_cn\":null,\"name_en\":\"Name_2\",\"name_ja\":null,\"name_zh_hk\":null},\"attributes\":{\"slug\":\"productmodelname9\",\"key\":\"iphone_2_case\",\"dir_name\":null,\"material\":null,\"weight\":null,\"enable_white\":false,\"auto_imposite\":false,\"name_zh_tw\":null,\"description_zh_tw\":null,\"short_name_zh_tw\":null,\"name_zh_cn\":null,\"description_zh_cn\":null,\"short_name_zh_cn\":null,\"name_en\":\"ProductModelName9\",\"description_en\":\"ProductModelName9 case\",\"short_name_en\":\"my short name\",\"name_ja\":null,\"description_ja\":null,\"short_name_ja\":null,\"name_zh_hk\":null,\"description_zh_hk\":null,\"short_name_zh_hk\":null,\"aasm_state\":\"customer\",\"code\":\"7TSD\",\"external_code\":null,\"width\":1.5,\"height\":1.5,\"dpi\":300,\"shape\":\"rectangle\",\"alignment_points\":\"none\",\"background_color\":null,\"padding_top\":\"0.0\",\"padding_right\":\"0.0\",\"padding_bottom\":\"0.0\",\"padding_left\":\"0.0\",\"enable_composite_with_horizontal_rotation\":false,\"create_order_image_by_cover_image\":false},\"preview_composers\":[{\"key\":null,\"type\":\"PreviewComposer::FrontBack\",\"available\":false,\"position\":1,\"background_width\":640,\"background_height\":480}]}]" }
  Given(:service) { Product::ImportService.new(json) }

  context '#init' do
    Then { service.product_attrs.size == 1 }
    And { service.product_attrs.first['product_key'] == 'iphone_2_case' }
    And { service.logs == [] }
  end

  context '#execute' do
    When { ProductModel.find_by(key: 'iphone_2_case').present? == false }
    When { ProductCategory.find_by(key: 'product_category_2').present? == false }
    Then { service.execute }
    And { service.logs.empty? == false }
    Given(:product) { ProductModel.find_by(key: 'iphone_2_case') }
    And { product.present? == true }
    And { product.category.key == 'product_category_2' }
    Given(:preview_composers) { product.preview_composers.first }
    And { preview_composers.type == "PreviewComposer::FrontBack" }
    And { preview_composers.background_width == 640 }
    And { preview_composers.background_height == 480 }
  end
end
