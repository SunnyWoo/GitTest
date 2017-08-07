cache_json_for json, @user do
  json.user do
    json.partial! 'api/v3/profile', user: @user
  end
end
