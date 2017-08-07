require 'spec_helper'

RSpec.describe 'api/v3/_standardized_work.json.jbuilder', :caching, type: :view do
  let(:work) { create(:standardized_work) }

  it 'renders standardized work' do
    render 'api/v3/standardized_work', work: work
    expect(JSON.parse(rendered)).to eq(
      'id' => work.id,
      'model_id' => work.model_id,
      'model' => work.product.name,
      'user_id' => work.user_id,
      'user_type' => work.user_type,
      'name' => work.name,
      'price_tier_id' => work.price_tier_id,
      'featured' => work.featured,
      'uuid' => work.uuid,
      'print_image_url' => work.print_image.url,
      'tag_ids' => work.tag_ids,
      'previews' => work.previews.map do |preview|
        {
          # these used in _work.json.jbuilder
          'normal' => preview.image.url,
          'thumb' => preview.image.thumb.url,
          # these used in work previews api
          'key' => preview.key,
          'url' => preview.image.url,
          # these used in standardized work api
          'image_url' => preview.image.url,
          'position' => preview.position
        }
      end,
      'output_files' => work.output_files.map do |output_file|
        {
          'id' => output_file.id,
          'key' => output_file.key,
          'file_url' => output_file.file.url
        }
      end
    )
  end

  it 'renders when standardized work model_id is nil' do
    work.update(model_id: nil)
    render 'api/v3/standardized_work', work: work
    expect(JSON.parse(rendered)).to eq(
      'id' => work.id,
      'model_id' => nil,
      'model' => nil,
      'user_id' => work.user_id,
      'user_type' => work.user_type,
      'name' => work.name,
      'price_tier_id' => work.price_tier_id,
      'featured' => work.featured,
      'uuid' => work.uuid,
      'print_image_url' => work.print_image.url,
      'tag_ids' => work.tag_ids,
      'previews' => work.previews.map do |preview|
        {
          # these used in _work.json.jbuilder
          'normal' => preview.image.url,
          'thumb' => preview.image.thumb.url,
          # these used in work previews api
          'key' => preview.key,
          'url' => preview.image.url,
          # these used in standardized work api
          'image_url' => preview.image.url,
          'position' => preview.position
        }
      end,
      'output_files' => work.output_files.map do |output_file|
        {
          'id' => output_file.id,
          'key' => output_file.key,
          'file_url' => output_file.file.url
        }
      end
    )
  end
end
