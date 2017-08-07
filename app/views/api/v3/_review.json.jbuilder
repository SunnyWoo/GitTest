cache_json_for json, review do
  json.user do
    json.partial! 'api/v3/user', user: review.user
  end
  json.user_id review.user_id
  # 為了維持相容而保留
  # 前端確認不使用後可移除
  json.user_name Monads::Optional.new(review).user.name.value
  # 為了維持相容而保留
  # 前端確認不使用後可移除
  json.user_avatar Monads::Optional.new(review).user.avatar.url.value
  json.call(review, :body, :star, :created_at)
end
