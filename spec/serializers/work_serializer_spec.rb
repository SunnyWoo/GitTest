# == Schema Information
#
# Table name: works
#
#  id                      :integer          not null, primary key
#  name                    :string(255)
#  description             :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  cover_image             :string(255)
#  work_type               :integer          default(1)
#  finished                :boolean          default(FALSE)
#  feature                 :boolean          default(FALSE)
#  uuid                    :string(255)
#  print_image             :string(255)
#  model_id                :integer
#  artwork_id              :integer
#  image_meta              :json
#  slug                    :string(255)
#  impressions_count       :integer          default(0)
#  ai                      :string(255)
#  pdf                     :string(255)
#  price_tier_id           :integer
#  attached_cover_image_id :integer
#  template_id             :integer
#  deleted_at              :datetime
#  user_type               :string(255)
#  user_id                 :integer
#  application_id          :integer
#  product_template_id     :integer
#  cradle                  :integer          default(0)
#  share_text              :text
#  variant_id              :integer
#

require 'spec_helper'

describe WorkSerializer do
  Given(:work) { create(:work) }
  Given(:user_hash) { JSON.parse(UserSerializer.new(work.user).to_json) }
  it 'works' do
    json = JSON.parse(WorkSerializer.new(work).to_json)
    expect(json).to eq(
      'work' => {
        'uuid' => work.uuid,
        'finished' => work.finished,
        'cover_image' => {
          'thumb' => work.cover_image.thumb.url,
          'normal' => work.cover_image.on_the_fly_process(resize_to_limit: [nil, 750]).url,
          'shop' => work.order_image.url
        },
        'name' => work.name,
        'model' => work.product_name,
        'product' => work.product_name,
        'category' => {
          'id' => work.category.id,
          'key' => work.category.key,
          'name' => work.category.name,
          'model' => {
            'id' => work.product.id,
            'key' => work.product_key,
            'name' => work.product_name
          },
          'product' => {
            'id' => work.product.id,
            'key' => work.product_key,
            'name' => work.product_name
          }
        },
        'editable' => (work.layers.length > 1),
        'feature' => work.feature,
        'prices' => work.prices,
        'original_prices' => work.product.prices,
        'preview_images' => work.previews.map(&:image_url),
        'user' => user_hash['user']
      }
    )
  end
end
