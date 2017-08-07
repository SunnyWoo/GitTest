cache_json_for json, @mobile_page do
  json.mobile_page do
    json.partial! 'api/v3/mobile_page', mobile_page: @mobile_page
  end
end
