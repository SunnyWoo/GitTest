cache_json_for json, @address_info do
  json.address_info do
    json.partial! 'api/v3/billing_profile', profile: @address_info
  end
end
