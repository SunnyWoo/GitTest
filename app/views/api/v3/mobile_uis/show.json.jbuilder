cache_json_for json, @mobile_ui do
  json.mobile_ui do
    json.partial! 'api/v3/mobile_ui', mobile_ui: @mobile_ui
  end
end
