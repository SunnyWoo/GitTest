require 'spec_helper'

RSpec.describe 'api/v3/_campaign_image', :caching, type: :view do
  let(:campaign_image) do
    file = fixture_file_upload('test.jpg', 'image/jpeg')
    create(:campaign_image, file: file, campaign_id: 1)
  end

  it 'renders campaing image' do
    render 'api/v3/campaign_image', image: campaign_image
    expect(JSON.parse(rendered)).to eq(
      'id' => campaign_image.id,
      'url' => campaign_image.file.url,
      'key' => campaign_image.key,
      'desc' => campaign_image.desc
    )
  end
end
