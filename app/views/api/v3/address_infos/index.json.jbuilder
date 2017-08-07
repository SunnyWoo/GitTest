json.cache! [cache_key_for_collection(@address_infos)] do
  json.address_infos do
    json.partial! 'api/v3/billing_profile', collection: @address_infos, as: :profile
  end
end
json.meta do
  json.address_count @address_infos.count
end
