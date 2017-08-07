json.pagination do
  json.extract!(models, :current_page, :next_page, :previous_page,
                :total_entries, :total_pages)
end
