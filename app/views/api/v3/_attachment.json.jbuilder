cache_json_for json, attachment do
  json.id attachment.aid
  json.url attachment.file.url
  json.call(attachment, :content_type, :size, :md5sum, :width, :height)
end
