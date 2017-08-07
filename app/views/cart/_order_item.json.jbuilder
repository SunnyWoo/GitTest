json.uuid order_item.itemable.uuid
json.name order_item.itemable.name
json.model_name order_item.itemable.product_name
json.order_image order_item.itemable.order_image.url
json.order_image_thumb order_item.itemable.order_image.thumb.url
json.quantity order_item.quantity
json.price order_item.itemable.price_in_currency(order_item.order.currency)
json.subtotal render_price(order_item.price_in_currency(order_item.order.currency) * order_item.quantity,
                           currency_code: order_item.order.currency)
json.del_path cart_path(id: order_item.itemable.uuid)
