json.bdevents do
  json.partial! 'bdevent', collection: @bdevents, as: :bdevent
end
