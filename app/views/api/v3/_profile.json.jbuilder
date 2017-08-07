cache_json_for json, user do
  json.call(user, :id, :name, :email)

  json.avatars do
    json.s35 user.avatar.s35.url
    json.s114 user.avatar.s114.url
    json.s154 user.avatar.s154.url
  end

  json.avatar_url user.avatar.url
  json.background_url user.background.url

  json.call(user, :gender, :location)

  json.works_count user.works.finished.count

  json.call(user, :role, :first_name, :last_name, :mobile, :mobile_country_code,
            :birthday)
end
