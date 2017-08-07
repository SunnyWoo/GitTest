admin = defined?(admin) && admin
json.cache! [note, admin: admin] do
  json.extract!(note, :id, :message, :created_at, :user_email)
  if admin == note.user
    json.links do
      json.update polymorphic_path([:admin, note.noteable, note], locale: I18n.locale)
    end
  end
end
