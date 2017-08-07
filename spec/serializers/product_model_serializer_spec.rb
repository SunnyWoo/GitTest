# == Schema Information
#
# Table name: product_models
#
#  id                                        :integer          not null, primary key
#  name                                      :string(255)
#  description                               :text
#  created_at                                :datetime
#  updated_at                                :datetime
#  available                                 :boolean          default(FALSE)
#  slug                                      :string(255)
#  category_id                               :integer
#  key                                       :string(255)
#  dir_name                                  :string(255)
#  placeholder_image                         :string(255)
#  price_tier_id                             :integer
#  design_platform                           :json
#  customize_platform                        :json
#  customized_special_price_tier_id          :integer
#  material                                  :string(255)
#  weight                                    :float
#  enable_white                              :boolean          default(FALSE)
#  auto_imposite                             :boolean          default(FALSE), not null
#  factory_id                                :integer
#  extra_info                                :json
#  aasm_state                                :string(255)
#  positions                                 :json             default(#<ProductModel::Positions:0x007ff27a813688 @ios=1, @android=1, @website=1>)
#  remote_key                                :string(255)
#  watermark                                 :string(255)
#  print_image_mask                          :string(255)
#  craft_id                                  :integer
#  spec_id                                   :integer
#  material_id                               :integer
#  code                                      :string(255)
#  external_code                             :string(255)
#  enable_composite_with_horizontal_rotation :boolean          default(FALSE)
#  create_order_image_by_cover_image         :boolean          default(FALSE)
#  enable_back_image                         :boolean          default(FALSE)
#  profit_id                                 :integer
#

require 'spec_helper'

describe ProductModelSerializer do
  it 'works' do
    price_tier = create(:price_tier, prices: { 'USD' => 5, 'TWD' => 200 })
    model = create(:product_model, customized_special_price_tier: price_tier)
    json = JSON.parse(ProductModelSerializer.new(model).to_json)
    expect(json).to eq(
      'product_model' => {
        'id' => model.id,
        'key' => model.key,
        'name' => model.name,
        'description' => model.description,
        'category' => {
          'id' => model.category.id,
          'key' => model.category.key
        },
        'short_name' => 'my short name',
        'currencies' => model.prices.map do |code, price|
          {
            'code' => code,
            'price' => price
          }
        end,
        'prices' => model.prices,
        'customized_special_prices' => model.customized_special_prices
      }
    )
  end
end
