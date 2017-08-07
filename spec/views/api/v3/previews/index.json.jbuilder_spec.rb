require 'spec_helper'

RSpec.describe 'api/v3/previews/index.json.jbuilder', :caching, type: :view do
  context 'when previews not ready' do
    let(:preview) { Preview.new(key: 'order-image') }

    it 'renders previews' do
      assign(:previews, [preview])
      render
      expect(JSON.parse(rendered)).to eq(
        'work' => {
          'ready' => false,
          'previews' => [{
            'id' => preview.id,
            # these used in _work.json.jbuilder
            'normal' => preview.image.url,
            'thumb' => preview.image.thumb.url,
            # these used in work previews api
            'key' => preview.key,
            'url' => preview.image.url,
            # these used in standardized work api
            'image_url' => preview.image.url,
            'position' => preview.position
          }]
        }
      )
    end
  end

  context 'when previews ready' do
    let(:preview) { create(:preview) }

    it 'renders previews' do
      assign(:previews, [preview])
      render
      expect(JSON.parse(rendered)).to eq(
        'work' => {
          'ready' => true,
          'previews' => [{
            'id' => preview.id,
            # these used in _work.json.jbuilder
            'normal' => preview.image.url,
            'thumb' => preview.image.thumb.url,
            # these used in work previews api
            'key' => preview.key,
            'url' => preview.image.url,
            # these used in standardized work api
            'image_url' => preview.image.url,
            'position' => preview.position
          }]
        }
      )
    end
  end
end
