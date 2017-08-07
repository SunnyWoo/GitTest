cache_json_for json, @wishlist do
  json.wishlist do
    json.partial! 'api/v3/wishlist', wishlist: @wishlist
  end
end
