cache_json_for json, @work do
  json.work do
    json.partial! 'admin/works/item', work: @work
  end
end
