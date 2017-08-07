json.standardized_works do
  json.partial! 'admin/standardized_works/item', collection: @works, as: :work
end
json.meta do
  json.query @query
  json.page @page
end
