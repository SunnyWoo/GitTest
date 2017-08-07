class ExportOrderMailer < ApplicationMailer
  layout false

  def daily_ship_orders(export_order_id)
    @export_order = ExportOrder.find(export_order_id)
    mail to: SiteSetting.by_key('DailyShipOrders'), subject: '每日出货订单'
  end
end
