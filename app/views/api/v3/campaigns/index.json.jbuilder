json.cache! [cache_key_for_collection(@campaigns)] do
  json.campaigns do
    json.partial! 'api/v3/campaign', collection: @campaigns, as: :campaign
  end
end
json.meta do
  json.count @campaigns.count
end
