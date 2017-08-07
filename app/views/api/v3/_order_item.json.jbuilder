order_item = Api::V3::OrderItemDecorator.new(order_item) unless order_item.is_a?(Api::V3::OrderItemDecorator)
cache_json_for json, order_item do
  json.quantity order_item.quantity
  json.price order_item.price_in_currency(order_item.order.currency)
  json.work_uuid order_item.itemable_uuid
  json.work_name order_item.itemable_name
  json.is_public order_item.itemable.is_public?
  json.user_display_name order_item.itemable.user_display_name
  json.model_name order_item.itemable.product_name
  json.model_key order_item.itemable.product.key
  json.product_name order_item.itemable.product_name
  json.product_key order_item.itemable.product.key
  json.order_image order_item.itemable.order_image.thumb.url
  json.partial! 'api/v3/unapproved_order_item', order_item: (order_item.is_a?(Api::V3::OrderItemDecorator) ? order_item.source : order_item)
end
