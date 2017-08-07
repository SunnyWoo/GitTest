cache_json_for json, home_slide do
  json.extract!(home_slide, :id, :set, :template)
  json.background home_slide.background.s1600.url
  json.slide home_slide.slide.url
  json.extract!(home_slide, :title, :link, :desc, :priority)
end
