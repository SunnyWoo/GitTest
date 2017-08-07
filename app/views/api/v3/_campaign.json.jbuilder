cache_json_for json, campaign do
  json.call(campaign, :id, :name, :key, :title, :desc, :designer_username,
            :artworks_class, :about_designer)
  json.campaign_images do
    json.partial! 'api/v3/campaign_image', collection: campaign.campaign_images, as: :image
  end
end
