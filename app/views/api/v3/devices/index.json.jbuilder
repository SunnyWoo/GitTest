json.cache! [cache_key_for_collection(@devices)] do
  json.devices do
    json.partial! 'api/v3/device', collection: @devices, as: :device
  end
end
