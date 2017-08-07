cache_json_for json, wishlist do
  json.id wishlist.id
  json.user_id wishlist.user_id
  json.user_type wishlist.user.try(:role)
  json.works do
    json.partial! 'api/v3/work', collection: wishlist.works, as: :work
  end
end
