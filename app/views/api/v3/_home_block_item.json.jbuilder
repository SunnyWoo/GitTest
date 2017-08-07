cache_json_for json, item do
  json.extract!(item, :id, :block_id, :title)
  json.title_translations full_translations(item.title_translations)
  json.extract!(item, :subtitle)
  json.subtitle_translations full_translations(item.subtitle_translations)
  json.extract!(item, :href)
  json.image item.pic.try(:thumb).try(:url)
  json.position item.position
  json.pic_translations full_translations(
    item.translations.each_with_object({}) do |t, hash|
      hash[t.locale.to_s] = t.pic.thumb.url
    end
  )
end
