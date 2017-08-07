cache_json_for json, @home_block do
  json.home_block do
    json.partial! 'api/v3/home_block', block: @home_block
  end
end
