cache_json_for json, @campaign do
  json.campaign do
    json.partial! 'api/v3/campaign', campaign: @campaign
  end
end
