json.cache! [@note, admin: current_admin] do
  json.note do
    json.partial! 'api/v3/note', note: @note, admin: current_admin
  end
end
