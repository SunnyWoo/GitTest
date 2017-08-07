cache_json_for json, device do
  json.call(device, :id, :user_id, :token, :detail, :os_version, :device_type,
            :endpoint_arn, :getui_client_id, :country_code, :timezone, :idfa)
end
