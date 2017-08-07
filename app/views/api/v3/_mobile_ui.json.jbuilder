# json.cache_if! mobile_ui.persisted?, mobile_ui do
  json.extract!(mobile_ui, :title, :template)
  json.links do
    json.set! '1x', mobile_ui.image.x_1.url
    json.set! '2x', mobile_ui.image.x_2.url
    json.set! '3x', mobile_ui.image.url
  end
# end
