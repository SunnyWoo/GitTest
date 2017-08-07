json.works do
  json.partial! 'admin/works/item', collection: @works, as: :work
end
json.meta do
  json.query @query
  json.page @page
end
