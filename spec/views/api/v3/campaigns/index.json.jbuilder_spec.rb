require 'spec_helper'

RSpec.describe 'api/v3/campaigns/index', type: :view do
  let(:campaign) do
    create(:campaign, campaign_images: [create(:campaign_image)])
  end

  it 'renders campaign' do
    assign(:campaigns, [campaign])
    render
    expect(JSON.parse(rendered)).to eq(
      'campaigns' => [{
        'id' => campaign.id,
        'name' => campaign.name,
        'key' => campaign.key,
        'title' => campaign.title,
        'desc' => campaign.desc,
        'designer_username' => campaign.designer_username,
        'artworks_class' => campaign.artworks_class,
        'about_designer' => campaign.about_designer,
        'campaign_images' => campaign.campaign_images.map do |image|
          {
            'id' => image.id,
            'url' => image.file.url,
            'key' => image.key,
            'desc' => image.desc
          }
        end
      }],
      'meta' => {
        'count' => 1
      }
    )
  end
end
