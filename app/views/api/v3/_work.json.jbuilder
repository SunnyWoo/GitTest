work = Pricing::ItemableDecorator.new(work) unless work.is_a?(Pricing::ItemableDecorator)
json.cache! [work.cache_key, defined?(scope) && scope.cache_key] do
  json.call(work, :id)
  json.gid work.to_gid_param
  json.call(work, :uuid, :name, :user_id)
  json.user_avatar work.user_avatar.as_json
  json.order_image do
    order_image = Monads::Optional.new(work.order_image)
    json.thumb order_image.thumb.url.value
    json.share order_image.share.url.value
    json.sample order_image.sample.url.value
    json.normal order_image.url.value
  end
  json.gallery_images do
    previews = work.respond_to?(:ordered_previews) ? work.ordered_previews : work.previews
    json.partial! 'api/v3/preview', collection: previews, as: :preview
  end
  json.call(work, :prices, :original_prices, :user_display_name)
  if defined?(scope)
    json.wishlist_included scope.wishlist.works.include?(work)
  else
    json.wishlist_included false
  end
  json.call(work, :slug)
  json.is_public work.is_public?
  json.user_avatars do
    json.s35 work.user.avatar.s35.url
    json.s154 work.user.avatar.s154.url
  end
  # TODO: remove this shit when spec can be remove safety
  json.spec do
    json.partial! 'api/v3/work_spec', spec: work.product
  end
  # TODO: remove this shit when model can be remove safety
  json.model do
    json.partial! 'api/v3/product_model', product: work.product
  end
  json.product do
    json.partial! 'api/v3/product_model', product: work.product
  end
  json.category do
    json.partial! 'api/v3/work_category', category: work.category
  end
  json.featured work.featured?
  if defined?(include_layers) && include_layers
    json.layers do
      json.partial! 'api/v3/layer', collection: work.layers, as: :layer
    end
  end
  json.tags do
    tags = work.tags
    json.partial! 'api/v3/tag', collection: tags, as: :tag
  end
end
