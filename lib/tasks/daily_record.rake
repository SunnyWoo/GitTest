namespace :daily_record do
  task store_order_sticker_info: :environment do
    order_ids = Order.paid.today.pluck(:id)
    items = OrderItem.where(order_id: order_ids)
    data = Report::OrderSticker::DataInfo.extract_from_order_items(items)
    Report::OrderSticker.create data: data, target_ids: order_ids
  end
end
