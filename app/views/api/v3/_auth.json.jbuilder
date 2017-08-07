cache_json_for json, auth do
  json.call(auth, :provider, :uid, :oauth_token, :owner_id, :owner_type)
end
