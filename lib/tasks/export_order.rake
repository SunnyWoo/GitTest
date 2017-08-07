namespace :export_order do
  task daily_ship_orders: :environment do
    export_order = ExportOrder.generate_export(Time.zone.yesterday.to_s)
    ExportOrderMailer.daily_ship_orders(export_order.id).deliver
  end
end
