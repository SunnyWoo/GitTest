json.mobile_pages do
  json.partial! 'api/v3/mobile_page', collection: @mobile_pages, as: :mobile_page
end
