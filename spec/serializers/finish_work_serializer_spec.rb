require 'spec_helper'

describe FinishWorkSerializer do
  Given(:work) { create(:work) }
  Given(:user_hash) { JSON.parse(UserSerializer.new(work.user).to_json) }
  it 'works' do
    json = JSON.parse(FinishWorkSerializer.new(work).to_json)
    expect(json).to eq(
      'finish_work' => {
        'uuid' => work.uuid,
        'name' => work.name,
        'description' => work.description,
        'model' => {
          'key' => work.product.key,
          'name' => work.product.name
        },
        'product' => {
          'key' => work.product.key,
          'name' => work.product.name
        },
        'cover_image' => {
          'thumb' => work.cover_image.thumb.url,
          'normal' => work.cover_image.url
        },
        'policy' => work.is_public? ? 'public' : 'private',
        'finished' => work.finished,
        'prices' => work.prices.to_hash,
        'original_prices' => work.product.prices,
        'layers' => [],
        'user' => user_hash['user'],
        'preview_images' => work.previews.map(&:image_url)
      }
    )
  end
end
