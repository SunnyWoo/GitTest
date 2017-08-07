class Imposition::DeliveryOrderUploader
  include Sidekiq::Worker
  sidekiq_options queue: :adobe

  def perform(delivery_order_id, factory_id)
    delivery_order = DeliveryOrder.find(delivery_order_id)
    factory = Factory.find(factory_id)
    delivery_order.generate_pdf
    factory.ftp_gateway.upload("tmp/#{delivery_order.order_no}.pdf", path: delivery_order.upload_path)
  end
end
